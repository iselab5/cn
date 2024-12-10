#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<errno.h>
#include<string.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<netinet/in.h>
#include<sys/socket.h>
#include<arpa/inet.h>
#include<sys/wait.h>
#include<signal.h>
#define MYPORT 6490
#define BACKLOG 10

int main(void)
{
    int sockfd, fp, new_fd;
    struct sockaddr_in my_addr, their_addr;
    int sin_size;
    int yes = 1;
    char buf1[40], buf2[20000];
    // Create socket
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        perror("socket");
        exit(1);
    }

    // Set socket options
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1) {
        perror("setsockopt");
        exit(1);
    }

    // Set up the address structure
    my_addr.sin_family = AF_INET;
    my_addr.sin_port = htons(MYPORT);
    my_addr.sin_addr.s_addr = INADDR_ANY;
    memset(&(my_addr.sin_zero), '\0', 8);

    // Bind the socket to the address
    if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof(struct sockaddr)) == -1)      {
        perror("bind");
        exit(1);
    }

    // Listen for connections
    if (listen(sockfd, BACKLOG) == -1) {
        perror("listen");
        exit(1);
    }

    printf("\nSERVER is online!\nSERVER: Waiting for the client...\n");
    sin_size = sizeof(struct sockaddr_in);

    // Accept a connection
    if ((new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size)) == -1) {
        perror("accept");
        exit(1);
    }

    printf("\nSERVER: Got connection from %s\n", inet_ntoa(their_addr.sin_addr));

    // Receive the file name from the client
    if (recv(new_fd, buf1, sizeof(buf1) - 1, 0) <= 0) {
        perror("recv");
        close(new_fd);
        close(sockfd);
        exit(1);
    }
    buf1[sizeof(buf1) - 1] = '\0'; // Ensure null-termination
    printf("SERVER: File requested: '%s'\n", buf1);

    // Open the file
    if ((fp = open(buf1, O_RDONLY)) < 0) {
        printf("File not found\n");
        strcpy(buf2, "File not found");
    } else {
        printf("SERVER: '%s' found and ready to transfer.\n", buf1);
        read(fp, buf2, sizeof(buf2));
        close(fp);
    }

    // Send file contents to the client
    send(new_fd, buf2, sizeof(buf2), 0);
    close(new_fd);
    close(sockfd);
    printf("Transfer successful\n");
    return 0;
}
