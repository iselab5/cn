#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<errno.h>
#include<string.h>
#include<netdb.h>
#include<sys/types.h>
#include<netinet/in.h>
#include<sys/socket.h>
#include<fcntl.h>

#define PORT 6490

int main()
{
    int sockfd;
    char buf1[40], buf2[20000];
    struct sockaddr_in their_addr;

    // Create socket
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        perror("socket");
        exit(1);
    }

    // Set up the address structure
    their_addr.sin_family = AF_INET;
    their_addr.sin_port = htons(PORT);
    their_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    memset(&(their_addr.sin_zero), '\0', 8);

    // Connect to the server
    if (connect(sockfd, (struct sockaddr *)&their_addr, sizeof(struct sockaddr)) == -1) {
        perror("connect");
        exit(1);
    }

    printf("CLIENT is online!\n");
    printf("CLIENT: Enter the filename to be displayed: ");
    
    // Get file name from user input
    if (fgets(buf1, sizeof(buf1), stdin) == NULL) {
        perror("fgets");
        close(sockfd);
        exit(1);
    }
    buf1[strcspn(buf1, "\n")] = '\0'; // Remove newline character
    printf("CLIENT: Sending file name '%s'\n", buf1);

    // Send the file name to the server
    if (send(sockfd, buf1, strlen(buf1) + 1, 0) == -1) {
        perror("send");
        close(sockfd);
        exit(1);
    }

    // Receive file content from the server
    if (recv(sockfd, buf2, sizeof(buf2), 0) == -1) {
        perror("recv");
        close(sockfd);
        exit(1);
    }

    // Display the content of the file or error message
    printf("Displaying the contents of '%s':\n", buf1);
    printf("\n%s\n", buf2);

    // Close the socket
    close(sockfd);
    return 0;
}
