#include <stdio.h>
#include <unistd.h>
#include <poll.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define GPIO_DIR "/sys/class/gpio"
#define GPIO_NAME "gpio539"
#define GPIO_PATH GPIO_DIR "/" GPIO_NAME "/"
#define GPIO_EXPORT GPIO_DIR "/export"
#define GPIO_UNEXPORT GPIO_DIR "/unexport"

int main(void)
{
    int fd, gpio_fd;
    int i;

    // GPIOエクスポート
    fd = open(GPIO_EXPORT, O_WRONLY);
    if (fd < 0)
    {
        perror("Failed to open export file");
        return EXIT_FAILURE;
    }
    write(fd, "539", strlen("539"));
    close(fd);

    // GPIO方向設定
    fd = open(GPIO_PATH "direction", O_WRONLY);
    if (fd < 0)
    {
        perror("Failed to set direction");
        return EXIT_FAILURE;
    }
    write(fd, "in", strlen("in"));
    close(fd);

    // 割り込みエッジ設定
    fd = open(GPIO_PATH "edge", O_WRONLY);
    if (fd < 0)
    {
        perror("Failed to set edge");
        return EXIT_FAILURE;
    }
    write(fd, "falling", strlen("falling"));
    close(fd);

    // GPIO値ファイルオープン
    gpio_fd = open(GPIO_PATH "value", O_RDWR);
    if (gpio_fd < 0)
    {
        perror("Failed to open value file");
        return EXIT_FAILURE;
    }

    for (i = 0; i < 3; i++)
    {
        char val;
        struct pollfd pfd;

        // 現在の値を読み取る
        lseek(gpio_fd, 0, SEEK_SET);
        read(gpio_fd, &val, sizeof(val));

        printf("Waiting for interrupt...\n");
        fflush(stdout);

        // 割り込み待機
        pfd.fd = gpio_fd;
        pfd.events = POLLIN;
        int ret = poll(&pfd, 1, -1); // タイムアウトなしで待機
        if (ret < 0)
        {
            perror("Poll failed");
            close(gpio_fd);
            return EXIT_FAILURE;
        }

        // 割り込み後の値を読み取る
        lseek(gpio_fd, 0, SEEK_SET);
        read(gpio_fd, &val, sizeof(val));

        printf("Interrupt detected! Value: %c (%s)\n",
               val, val == '0' ? "Low" : "High");

        sleep(1); // デバッグ用ウェイト
    }

    close(gpio_fd);

    // GPIOアンエクスポート
    fd = open(GPIO_UNEXPORT, O_WRONLY);
    if (fd < 0)
    {
        perror("Failed to open unexport file");
        return EXIT_FAILURE;
    }
    write(fd, "539", strlen("539"));
    close(fd);

    return EXIT_SUCCESS;
}
