void addImpulse(vector <INT32> &impulseList, INT32 index, DOUBLE data)
{
	// extend array (3 * 32bit)
	impulseList.resize(impulseList.size()+3);
	// add index as the first value (32bit)
	impulseList[impulseList.size()-3] = index;
	// use the next two values to store the 64bit data
	DOUBLE * dataPtr = (DOUBLE *) &(impulseList[impulseList.size()-2]);
	*dataPtr = data;
}

void getImpulse(INT32 * impulseList, INT32 lookupIndex, INT32 &outIndex, DOUBLE &outData)
{
	// offset into the array
	outIndex = impulseList[lookupIndex];
	outData = *((DOUBLE *) (&impulseList[lookupIndex + 1]));
}
