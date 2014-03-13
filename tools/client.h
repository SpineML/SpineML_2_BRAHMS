#define RESP_DATA_NUMS 31
#define RESP_DATA_SPIKES 32
#define RESP_DATA_IMPULSES 33
#define RESP_HELLO 41
#define RESP_AM_SOURCE 45
#define RESP_AM_TARGET 46
#define RESP_RECVD 42
#define RESP_ABORT 43
#define RESP_FINISHED 44

#include <iostream>

enum dataTypes {
	ANALOG,
	EVENT,
	IMPULSE
};

class spineMLNetworkClient;

class spineMLNetworkClient {

	public:
	spineMLNetworkClient() {}
	~spineMLNetworkClient() {}
	
	bool connectClient(int portno);
	bool handShake(char);
	bool sendDataType(dataTypes dataType);
	dataTypes recvDataType(bool &ok);
	bool sendSize(int size);
	int recvSize(bool &ok);	
	bool sendData(char * ptr, int size);
	bool recvData(char * data, int size);
	bool sendContinue();
	bool sendEnd();
	bool disconnectClient();
	
	private:
    int sockfd;
    int n;
    struct sockaddr_in serv_addr;
    struct hostent *server;
	char returnVal;
    char sendVal;
    
};

bool spineMLNetworkClient::connectClient(int portno) {
	
	//std::cout << "connect\n";
	
	// connect the socket:

    // copy / pasted from an example with minor modifications...
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0)
        berr << "Error opening socket";
    server = gethostbyname("localhost");
    if (server == NULL) {
        berr << "Error connecting to localhost";     
    }
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr,
          (char *)&serv_addr.sin_addr.s_addr,
          server->h_length);
    serv_addr.sin_port = htons(portno);
    
    // need some looping here for if source takes a while to start up...
    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0)
        berr << "Error connecting to External program";
	
	return true;
}

bool spineMLNetworkClient::handShake(char type) {

	//std::cout << "handshake send\n";
            
    // send first
    sendVal = type;
    n = send(sockfd,&sendVal,1, MSG_WAITALL);
    if (n < 1)
        berr << "Error writing to socket (handShake)";
    
    //std::cout << "handshake reply recv\n";
    
    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1)
        berr << "Error writing to socket (handShake)";
    
    if (returnVal != RESP_HELLO)
        berr << "Error handshaking";

	return true;
}

bool spineMLNetworkClient::sendDataType(dataTypes dataType) {

	//std::cout << "dataType send\n";

    // send the data type
    switch (dataType) {
    	case ANALOG:
    		sendVal = RESP_DATA_NUMS;
    		break;
    	case EVENT:
    		sendVal = RESP_DATA_SPIKES;
    		break;
    	case IMPULSE:
     		sendVal = RESP_DATA_IMPULSES;
    		break;           	
    }
    
    n = send(sockfd,&sendVal,1, MSG_WAITALL);
    if (n < 1)
        berr << "Error writing to socket (sendDataType)";

	//std::cout << "dataType reply recv\n";

    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1)
        berr << "Error reading from socket (sendDataType)";
        
    if (returnVal == RESP_ABORT)
    	berr << "External target aborted the simulation due to the data type"; 

	return true;
}

dataTypes spineMLNetworkClient::recvDataType(bool &ok) {

	//std::cout << "dataType recv\n";

    // get dataType
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1)
        berr << "Error reading from socket (recvDataType)";
        
    if (returnVal != RESP_DATA_NUMS && returnVal != RESP_DATA_SPIKES && returnVal != RESP_DATA_IMPULSES)
    	berr << "Bad data (recvDataType)";
    	
    //std::cout << "dataType reply send\n";	
    	
    sendVal = RESP_RECVD;
    	
    n = send(sockfd,&sendVal,1, MSG_WAITALL);
    if (n < 1)
        berr << "Error writing to socket (recvDataType)"; 
        
   dataTypes dataType;     
   switch (returnVal) {
    	case RESP_DATA_NUMS:
    		dataType = ANALOG;
    		break;
    	case RESP_DATA_SPIKES:
    		dataType = EVENT;
    		break;
    	case RESP_DATA_IMPULSES:
     		dataType = IMPULSE;
    		break;           	
    }

	return (dataTypes) dataType;

}

bool spineMLNetworkClient::sendSize(int size) {

	//std::cout << "size send\n";

	// send size
    n = send(sockfd,&size,sizeof(int), MSG_WAITALL);
    if (n < 1)
        berr << "Error writing to socket (sendSize)";

	//std::cout << "size reply recv\n";

    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1)
        berr << "Error reading from socket (sendSize)";
        
    if (returnVal == RESP_ABORT)
    	berr << "External target aborted the simulation due to the data size"; 

//std::cout << "size reply recv'd\n";

	return true;

}

int spineMLNetworkClient::recvSize(bool &ok) {

	//std::cout << "size recv\n";

	int size;

    // get size
    n = recv(sockfd,&(size),sizeof(size), MSG_WAITALL);
    if (n < 1)
        berr << "Error reading from socket (recvSize)";
        
    if (size < 0)
    	berr << "Bad data (recvSize)";
    	
    sendVal = RESP_RECVD;
    
    //std::cout << "size reply send\n";
    	
    n = send(sockfd,&sendVal,1, MSG_DONTWAIT);
    if (n < 1)
        berr << "Error writing to socket (recvSize)"; 

	return size;

}

bool spineMLNetworkClient::sendData(char * ptr, int size) {

	// send data
	int sent_bytes = 0;
	while (sent_bytes < size)
    	sent_bytes += send(sockfd,ptr+sent_bytes,size, MSG_DONTWAIT);
    n = sent_bytes;
    if (n < 1)
        berr << "Error writing to socket  (sendData)";

    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1)
        berr << "Error reading from socket  (sendData)";
        
    if (returnVal == RESP_ABORT)
    	berr << "External target aborted the simulation after send data"; 

	return true;

}

bool spineMLNetworkClient::recvData(char * data, int size) {

	//std::cout << "recvdata\n";

    // get data
    int recv_bytes = 0;
	while (recv_bytes < size) {
    	recv_bytes += recv(sockfd,data+recv_bytes,size, MSG_WAITALL);
    	}
    n = recv_bytes;
    if (n < 1)
        berr << "Error reading from socket for External Input";
        
    //std::cout << "received " << float(recv_bytes) << " of data!\n";
        
    if (size < 0)
    	berr << "Bad data sent to external input";
    	
    //std::cout << "recvdata reply\n";
    	
    sendVal = RESP_RECVD;
    	
    n = send(sockfd,&sendVal,1, MSG_DONTWAIT);
    if (n < 1)
        berr << "Error writing to socket for External Input"; 
        
    return true;
}

bool spineMLNetworkClient::sendContinue() {

/*	sendVal = RESP_FINISHED;

	int sent_bytes = 0;
	while (sent_bytes < size)
    	sent_bytes += send(sockfd,ptr+sent_bytes,1, MSG_DONTWAIT);
    n = sent_bytes;
    if (n < 1)
        berr << "Error writing to socket  (sendData)";
    */
}

bool spineMLNetworkClient::sendEnd() {

/*	sendVal = RESP_FINISHED;

	int sent_bytes = 0;
	while (sent_bytes < size)
    	sent_bytes += send(sockfd,ptr+sent_bytes,1, MSG_DONTWAIT);
    n = sent_bytes;
    if (n < 1)
        berr << "Error writing to socket  (sendData)";
    */
}

bool spineMLNetworkClient::disconnectClient() {

	sendVal = RESP_FINISHED;

	// close tcp / ip
	/*n = send(sockfd,&sendVal,1);
    if (n < 1)
        berr << "Error writing to socket for External Output";*/
    close(sockfd);
    
}


