#include <stdio.h>
#include <pigpio.h>
#include <stdlib.h>
#include <signal.h> // signal用

// プログラム終了処理
void cleanup()
{
    printf("プログラム終了: gpioTerminate()を呼び出します。\n");
    gpioTerminate();
}

// SIGINTシグナル（Ctrl+C）ハンドラ
void sigint_handler(int signum)
{
    printf("\nSIGINT受信: プログラムを終了します。\n");
    exit(0); // atexitで登録されたcleanup()が呼ばれる
}

// ボタン状態変化時の処理
#define SW_LONG_MSEC 3000

int onLevel; // ボタンonの電圧レベル

void sw_callback(int gpio, int level, uint32_t tick)
{
    int off_level = !onLevel;

    // on？ (off→on)
    if (level == onLevel)
    {
        // 0 は ping が成功 = サーバが起動中
        if (system("ping 192.168.11.7 -c 1 -w 1") == 0)
        {
            // シャットダウン実行判定用のウォッチドッグ開始
            printf("ウォッチドッグを開始します。\n");
            gpioSetWatchdog(gpio, SW_LONG_MSEC);
        }
        else
        {
            // サーバー起動
            // system("wol 50:eb:f6:b9:16:8a");
            printf("サーバーを起動します。\n");
        }
    }
    // off？ (on→off)
    else if (level == off_level)
    {
        // ウォッチドッグ停止
        printf("ウォッチドッグを停止します。\n");
        gpioSetWatchdog(gpio, 0);
    }
    // ウォッチドッグ タイムアウト → 3秒間押された
    else
    {
        // サーバーをシャットダウン
        printf("サーバーをシャットダウンします。\n");
    }
}

int main()
{
    //------------------------------
    // 回路構成に合わせた設定

    // ボタンのBCM番号
    int sw_pin = 24;

    // 内部プルアップ(PI_PUD_UP)/プルダウン(PI_PUD_DOWN)、使用しない(PI_PUD_OFF)
    int sw_pud = PI_PUD_UP;

    //------------------------------
    // ライブラリの初期化
    if (gpioInitialise() < 0)
    {
        fprintf(stderr, "pigpioの初期化に失敗しました。\n");
        return 1;
    }

    if (atexit(cleanup) != 0)
    {
        fprintf(stderr, "atexit関数の登録に失敗しました。\n");
        gpioTerminate();
        return 1;
    }

    signal(SIGINT, sigint_handler); // SIGINTシグナルハンドラを登録

    //------------------------------
    // GPIOに関する初期設定

    // ボタンon時の電圧レベル
    //   ボタンを押したとき電圧高なら「1」
    //   ボタンを押したとき電圧低なら「0」
    onLevel = 0;

    // ボタンのピンを入力として使用
    gpioSetMode(sw_pin, PI_INPUT);

    // ボタンのピンの内部プルアップ/プルダウン/使用しないの設定
    gpioSetPullUpDown(sw_pin, sw_pud);

    //------------------------------
    // ピンの値を読み取る

    // ボタン状態変化時のコールバック関数を登録
    gpioSetAlertFunc(sw_pin, sw_callback);

    //------------------------------

    // ループ
    printf("GPIO[%d]の状態変化を監視中です。Ctrl+Cで終了してください。\n", sw_pin);
    while (1)
    {
        // 待機
        time_sleep(1);
    }

    return 0;
}
