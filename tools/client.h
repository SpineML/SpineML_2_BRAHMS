#define RESP_DATA_NUMS 31
#define RESP_DATA_SPIKES 32
#define RESP_DATA_IMPULSES 33
#define RESP_HELLO 41
#define RESP_AM_SOURCE 45
#define RESP_AM_TARGET 46
#define RESP_RECVD 42
#define RESP_ABORT 43
#define RESP_FINISHED 44
#define NOT_SET 99

#include <iostream>
#include <arpa/inet.h>
#include <fcntl.h>
#include <iostream>
#include <netdb.h>
#include <string>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/tcp.h>

enum dataTypes {
    ANALOG,
    EVENT,
    IMPULSE
};

class spineMLNetworkClient;

/*!
 * This is a mask used to pick out the "loops" which will cause output
 * of debug data about receiving data over the wire.
 */
#define RECVDEBUG_MASK 0xffffffff

class spineMLNetworkClient {

public:
    spineMLNetworkClient() : recvDebug(0) {}
    ~spineMLNetworkClient() {}

    string getLastError();
    bool createClient(string, int, int, dataTypes, int, string connectionName = "unset");
    bool connectClient(int portno, string hostname = "localhost");
    bool handShake(char);
    bool sendDataType(dataTypes dataType);
    dataTypes recvDataType(bool &ok);
    bool sendSize(int size);
    bool sendName(const string& connName);
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
    string error;

    /*!
     * recvDebug is used to determine if an info message about
     * receiving data should be emitted (to stdout). When this is 0,
     * 1, 10, 100, 1000, 2000 etc a message will be sent to
     * stdout. This is an attempt to give the user some confidence
     * that incoming data from a network connection is being received,
     * without swamping the BRAHMS output log.
     */
    int recvDebug;
};

string spineMLNetworkClient::getLastError()
{
    return error;
}

bool spineMLNetworkClient::createClient(string hostname, int port, int size,
                                        dataTypes datatype, int targetOrSource, string connectionName)
{
    error = "done start";

    if (!this->connectClient(port, hostname.c_str())) {
        //if (!this->connectClient(port, "143.167.10.48")) {
        return false;
    }
    error = "done connect";

    if (!this->handShake(targetOrSource)) {
        return false;
    }
    error = "done handshake";

    bool ok;

    ok = this->sendDataType(datatype);
    if (!ok) {
        return false;
    }
    error = "done type";

    ok = this->sendSize(size);
    if (!ok) {
        return false;
    }
    error = "done size";

    ok = this->sendName(connectionName);
    if (!ok) {
        return false;
    }
    error = "done name";

    return true;
}

bool spineMLNetworkClient::connectClient(int portno, string hostname)
{
    //std::cout << "connect\n";

    // connect the socket:

    // copy / pasted from an example with minor modifications...
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    int flag = 1;
    // length of option value:
    int result = setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *) &flag, sizeof(int));
    if (result < 0) {
    	error = "Error setting socket options";
    	return false;
    }

    if (sockfd < 0) {
        error =  "Error opening socket";
        return false;
    }
    /*server = gethostbyname(hostname.c_str());
      if (server == NULL) {
      error =  "Error connecting to server";
      return false;
      }*/
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    /*bcopy((char *)server->h_addr,
      (char *)&serv_addr.sin_addr.s_addr,
      server->h_length);*/
    serv_addr.sin_addr.s_addr = inet_addr(hostname.c_str());
    serv_addr.sin_port = htons(portno);

    // need some looping here for if source takes a while to start up...
    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) {
        error =  "Error connecting to External program";
        return false;
    }

    return true;
}

bool spineMLNetworkClient::handShake(char type)
{
    //std::cout << "handshake send\n";

    // send first
    sendVal = type;
    n = send(sockfd,&sendVal,1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error writing to socket (handShake)";
        return false;
    }

    //std::cout << "handshake reply recv\n";

    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error reading from socket (handShake)";
        return false;
    }

    if (returnVal != RESP_HELLO) {
        error =  "Error handshaking";
        return false;
    }

    return true;
}

bool spineMLNetworkClient::sendDataType(dataTypes dataType)
{
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
    default:
        sendVal = NOT_SET;
        break;
    }

    if (sendVal == NOT_SET) {
        error = "Error - wrong value for dataType (sendDataType)";
        return false;
    }

    n = send(sockfd,&sendVal,1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error writing to socket (sendDataType)";
        return false;
    }

    //std::cout << "dataType reply recv\n";

    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error reading from socket (sendDataType)";
        return false;
    }

    if (returnVal == RESP_ABORT) {
        error =  "External target aborted the simulation due to the data type";
        return false;
    }

    return true;
}

dataTypes spineMLNetworkClient::recvDataType(bool &ok)
{
    //std::cout << "dataType recv\n";

    // get dataType
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error reading from socket (recvDataType)";
        ok = false;
        return IMPULSE;
    }

    if (returnVal != RESP_DATA_NUMS && returnVal != RESP_DATA_SPIKES && returnVal != RESP_DATA_IMPULSES) {
    	error =  "Bad data (recvDataType)";
        ok = false;
        return IMPULSE;
    }

    //std::cout << "dataType reply send\n";

    sendVal = RESP_RECVD;

    n = send(sockfd,&sendVal,1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error writing to socket (recvDataType)";
        ok = false;
        return IMPULSE;
    }

    dataTypes dataType = ANALOG;
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
    default:
        dataType = ANALOG;
        break;
    }

    return (dataTypes) dataType;
}

/*!
 * Send the \param size over the network - \param size is the number
 * of double-precision numbers (4 bytes per double) which should be
 * transmitted for each timestep in the simulation/execution.
 */
bool spineMLNetworkClient::sendSize(int size)
{
    //std::cout << "size send\n";

    // send size
    n = send(sockfd, &size, sizeof(int), MSG_WAITALL);
    if (n < 1) {
        error =  "Error writing to socket (sendSize)";
        return false;
    }

    //std::cout << "size reply recv\n";

    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error reading from socket (sendSize)";
        return false;
    }

    if (returnVal == RESP_ABORT) {
        error =  "External target aborted the simulation due to the data size";
        return false;
    }

    //std::cout << "size reply recv'd\n";

    return true;
}

bool spineMLNetworkClient::sendName(const string& connName)
{
    // send connection name, preceded by its length in bytes.
    int namesize = connName.size();
    n = send(sockfd, &namesize, sizeof(int), MSG_WAITALL);
    if (n < 1) {
        error =  "Error writing name size to socket (sendName)";
        return false;
    }
    n = send(sockfd, connName.c_str(), namesize, MSG_WAITALL);
    if (n < 1) {
        error =  "Error writing name to socket (sendName)";
        return false;
    }

    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error reading from socket (sendName)";
        return false;
    }

    if (returnVal == RESP_ABORT) {
        error =  "External target aborted the simulation as it didn't like the name!";
        return false;
    }

    return true;
}

/*!
 * Receive (from the network) the "size" - the number of
 * double-precision numbers (4 bytes per double) which should be
 * transmitted for each timestep in the simulation/execution.
 *
 * \return Number of doubles of data transmitted per timestep.
 */
int spineMLNetworkClient::recvSize(bool &ok)
{
    //std::cout << "size recv\n";

    int size;

    // get size
    n = recv(sockfd,&(size),sizeof(size), MSG_WAITALL);
    if (n < 1) {
        error =  "Error reading from socket (recvSize)";
        ok = false;
        return 0;
    }

    if (size < 0) {
    	error =  "Bad data (recvSize)";
        ok = false;
        return 0;
    }

    sendVal = RESP_RECVD;

    //std::cout << "size reply send\n";

    n = send(sockfd,&sendVal,1, MSG_DONTWAIT);
    if (n < 1) {
        error =  "Error writing to socket (recvSize)";
        ok = false;
        return 0;
    }

    return size;
}

/*!
 * Send
 */
bool spineMLNetworkClient::sendData(char * ptr, int datasizeBytes)
{
    // send data
    int sent_bytes = 0;
    while (sent_bytes < datasizeBytes) {
        sent_bytes += send(sockfd,ptr+sent_bytes,datasizeBytes, MSG_DONTWAIT);
    }
    n = sent_bytes;
    if (n < 1) {
        error =  "Error writing to socket  (sendData)";
        return false;
    }

    //cout << "Sent data" << endl;

    // get reply
    n = recv(sockfd,&(returnVal),1, MSG_WAITALL);
    if (n < 1) {
        error =  "Error reading from socket  (sendData)";
        return false;
    }

    if (returnVal == RESP_ABORT) {
    	error =  "External target aborted the simulation after send data";
    	return false;
    }
    //cout << "data send confirmed" << endl;;

    return true;
}

/*!
 * datasizeBytes is 4 * the size sent by sendSize or received by recvSize.
 */
bool spineMLNetworkClient::recvData(char * data, int datasizeBytes)
{
    bool outputDebug = false;
    if (this->recvDebug == 0x1 || this->recvDebug == 0x2
        || this->recvDebug == 0x10 || this->recvDebug == 0x80
        || !(this->recvDebug%1000)) {
        outputDebug = true;
    }
    int loopNum = this->recvDebug;
    this->recvDebug++;

    if (outputDebug) {
        std::cout << "recvdata called to receive " << datasizeBytes
                  << " input bytes. Loop num is " << loopNum << "\n";
    }
    // get data
    int recv_bytes = 0;
    while (recv_bytes < datasizeBytes) {
        recv_bytes += recv(sockfd,data+recv_bytes,datasizeBytes, MSG_WAITALL);
    }
    n = recv_bytes;
    if (n < 1) {
        error =  "Error reading from socket for External Input";
        return false;
    }

    if (outputDebug) {
        std::cout << "received " << float(recv_bytes) << " of data!\n";
    }

    if (datasizeBytes < 0) {
    	error =  "Bad data sent to external input";
    	return false;
    }

    //std::cout << "recvdata reply\n";

    sendVal = RESP_RECVD;

    n = send(sockfd,&sendVal,1, MSG_DONTWAIT);
    if (n < 1) {
        error =  "Error writing to socket for External Input";
        return false;
    }

    return true;
}

bool spineMLNetworkClient::sendContinue()
{
/*	sendVal = RESP_FINISHED;

	int sent_bytes = 0;
	while (sent_bytes < size)
    	sent_bytes += send(sockfd,ptr+sent_bytes,1, MSG_DONTWAIT);
        n = sent_bytes;
        if (n < 1)
        error =  "Error writing to socket  (sendData)";
*/

    return true;
}

bool spineMLNetworkClient::sendEnd()
{
/*	sendVal = RESP_FINISHED;

	int sent_bytes = 0;
	while (sent_bytes < size)
    	sent_bytes += send(sockfd,ptr+sent_bytes,1, MSG_DONTWAIT);
        n = sent_bytes;
        if (n < 1)
        error =  "Error writing to socket  (sendData)";
*/

    return true;
}

bool spineMLNetworkClient::disconnectClient()
{
    sendVal = RESP_FINISHED;

    // close tcp / ip
    /*n = send(sockfd,&sendVal,1);
      if (n < 1)
      error =  "Error writing to socket for External Output";*/
    close(sockfd);

    return true;
}
