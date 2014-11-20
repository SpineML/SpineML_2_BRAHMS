<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:param name="spineml_run_dir" select="'../../'"/>

<xsl:include href="SpineML_helpers.xsl"/>

<xsl:template match="/">

<xsl:for-each select="/SMLLOWNL:SpineML/SMLLOWNL:Population">
<!-- Here we use the population number to determine which Neuron type we are outputting -->
<xsl:variable name="number"><xsl:number count="/SMLLOWNL:SpineML/SMLLOWNL:Population" format="1"/></xsl:variable>
<xsl:if test="$number = number(document(concat($spineml_run_dir,'/counter.file'))/Number)">

<xsl:variable name="linked_file" select="document(./SMLLOWNL:Neuron/@url)"/>
<xsl:variable name="process_name"><xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/></xsl:variable>

/*
   Autogenerated BRAHMS process from SpineML description.
   Engine: XSLT
   Engine Author: Alex Cope 2012
   Node name: <xsl:value-of select="SMLLOWNL:Neuron/@url"/>
*/


#define COMPONENT_CLASS_STRING "dev/SpineML/temp/NB/<xsl:value-of select="$process_name"/>"
#define COMPONENT_CLASS_CPP dev_spineml_nb_<xsl:value-of select="$process_name"/>_0
#define COMPONENT_RELEASE 0
#define COMPONENT_REVISION 1
#define COMPONENT_ADDITIONAL "Author=SpineML_2_BRAHMS\n" "URL=Not supplied\n"
#define COMPONENT_FLAGS (F_NOT_RATE_CHANGER)

#define OVERLAY_QUICKSTART_PROCESS

//	include the component interface overlay (component bindings 1199)
#include "brahms-1199.h"

//	alias data and util namespaces to something briefer
namespace numeric = std_2009_data_numeric_0;
namespace spikes = std_2009_data_spikes_0;
namespace rng = std_2009_util_rng_0;

using namespace std;

#include "rng.h"
// Some very SpineML_2_BRAHMS specific defines, common to all components.
#define randomUniform     _randomUniform(&amp;this-&gt;rngData_BRAHMS)
#define randomNormal      _randomNormal(&amp;this-&gt;rngData_BRAHMS)
#define randomExponential _randomExponential(&amp;this-&gt;rngData_BRAHMS)
#define randomPoisson     _randomPoisson(&amp;this-&gt;rngData_BRAHMS)
#include "impulse.h"

/* helper function for doing the indexing... do we need this?
int getIndex(VDOUBLE position, VDOUBLE size) {

	int index = 0;
	int mult = 1;
	for (int i = 0; i &lt; size.size(); ++i) {
		index = index + pos[i] * mult;
		mult = mult * size[i];
	}

}*/

// structure allowing weights to be sent with spikes
struct INT32SINGLE {
	INT32 i;
	SINGLE s;
};

float dt;

//float integrate(float, float);

// solver - could use better one!
/*float integrate(float x, float dx) {

	return x + dx*dt;

}*/

class COMPONENT_CLASS_CPP;

<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics">
<xsl:apply-templates select="SMLCL:Regime" mode="defineTimeDerivFuncsPtr1"/>
</xsl:for-each>


////////////////	COMPONENT CLASS (DERIVES FROM Process)

class COMPONENT_CLASS_CPP : public Process
{

public:

	//	use ctor/dtor only if required
	COMPONENT_CLASS_CPP() {}
	~COMPONENT_CLASS_CPP() {bout &lt;&lt; "FINISHED" &lt;&lt; D_INFO;}

	//	the framework event function
	Symbol event(Event* event);

private:

// Some data for the random number generator.
RngData rngData_BRAHMS;

float t;

// base name
string baseNameForLogs_BRAHMS;

// model directory string
string modelDirectory_BRAHMS;

// define regimes
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics">
<xsl:apply-templates select="SMLCL:Regime" mode="defineRegime"/>
</xsl:for-each>


// Global variables
vector &lt; int &gt; <xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime;
vector &lt; int &gt; <xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regimeNext;


VDOUBLE size_BRAHMS;
int numElements_BRAHMS;

// Analog Ports
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
<xsl:apply-templates select="SMLCL:AnalogReceivePort | SMLCL:AnalogSendPort | SMLCL:AnalogReducePort" mode="defineAnalogPorts"/>
</xsl:for-each>

// Event Ports
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
<xsl:apply-templates select="SMLCL:EventReceivePort | SMLCL:EventSendPort" mode="defineEventPorts"/>
</xsl:for-each>

// Impulse Ports
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
<xsl:apply-templates select="SMLCL:ImpulseReceivePort | SMLCL:ImpulseSendPort" mode="defineImpulsePorts"/>
</xsl:for-each>

// State Variables
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics">
<xsl:apply-templates select="SMLCL:StateVariable" mode="defineStateVariable"/>
</xsl:for-each>

// Parameters
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
<xsl:apply-templates select="SMLCL:Parameter" mode="defineParameter"/>
</xsl:for-each>

// Add aliases that are not inputs
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass//SMLCL:Alias">
<xsl:variable name="aliasName" select="@name"/>
<xsl:if test="count(//SMLCL:AnalogSendPort[@name=$aliasName])=0">
<xsl:apply-templates select="." mode="defineAlias"/>
</xsl:if>
</xsl:for-each>

<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics">
<xsl:apply-templates select="SMLCL:Regime" mode="defineTimeDerivFuncs"/>
</xsl:for-each>

// euler
float integrate(float x, float (COMPONENT_CLASS_CPP::*func)(float, int), int num) {

	return x + (*this.*func)(x,num)*dt;

}
/*
// Runge Kutta 4th order
float integrate(float x, float (COMPONENT_CLASS_CPP::*func)(float, int), int num) {

	float k1 = dt*(*this.*func)(x,num);
	float k2 = dt*(*this.*func)(x+0.5*k1,num);
	float k3 = dt*(*this.*func)(x+0.5*k2,num);
	float k4 = dt*(*this.*func)(x+k3,num);
	return x + (1.0/6.0)*(k1 + 2.0*k2 + 2.0*k3 + k4);

}*/

float old_vals[3];

// Adams Bashforth 3rd order
/*float integrate(float x, float (COMPONENT_CLASS_CPP::*func)(float, int), int num) {

	for (int i = 0; i &lt; 2; ++i)
		{old_vals[i] = old_vals[i+1];}
	old_vals[2] = (*this.*func)(x,num);
	return x + dt*((23.0/12.0)*old_vals[2] -(4.0/3.0)*old_vals[1] + (5.0/12.0)*old_vals[0]);;
}*/

};

////////////////	EVENT

Symbol COMPONENT_CLASS_CPP::event(Event* event)
{
	switch(event->type)
	{
		case EVENT_STATE_SET:
		{
			//	extract DataML
			EventStateSet* data = (EventStateSet*) event->data;
			XMLNode xmlNode(data->state);
			DataMLNode nodeState(&amp;xmlNode);

			rngDataInit(&amp;this-&gt;rngData_BRAHMS);
			zigset(&amp;this-&gt;rngData_BRAHMS, 11);

			// obtain the parameters
			size_BRAHMS = nodeState.getField("size").getArrayDOUBLE();
			numElements_BRAHMS = 1;
			for (int i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; size_BRAHMS.size(); ++i_BRAHMS_LOOP) {
				numElements_BRAHMS *= size_BRAHMS[i_BRAHMS_LOOP];
			}

			// Ensure field is present (trigger BRAHMS error if not)
			modelDirectory_BRAHMS = nodeState.getField("model_directory").getSTRING();

			int numEl_BRAHMS = numElements_BRAHMS;

			// State Variables
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics">
<xsl:apply-templates select="SMLCL:StateVariable" mode="assignStateVariable"/>
</xsl:for-each>

			// Parameters
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
<xsl:apply-templates select="SMLCL:Parameter" mode="assignParameter"/>
</xsl:for-each>

			// Alias resize
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics">
<xsl:apply-templates select="SMLCL:Alias" mode="resizeAlias"/>
</xsl:for-each>

			<!-- Log base name - note log directory is adjacent to spine_run_dir -->
			baseNameForLogs_BRAHMS = "../log/" + nodeState.getField("logfileNameForComponent").getSTRING();
			<!-- State variable names -->
			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:StateVariable">
				<xsl:value-of select="@name"/>_BINARY_FILE_NAME_OUT = "../model/" + nodeState.getField("<xsl:value-of select="@name"/>BIN_FILE_NAME").getSTRING();
			</xsl:for-each>

			// Logs
<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
<xsl:apply-templates select="SMLCL:AnalogSendPort | SMLCL:EventSendPort" mode="createSendPortLogs"/>
</xsl:for-each>

<xsl:text>
            </xsl:text>
            <!-- SELECT INITIAL_REGIME, OR DEFAULT TO REGIME 1 -->
            <xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime.resize(numEl_BRAHMS,<!---->
            <xsl:if test="$linked_file//SMLCL:Dynamics/@initial_regime">
            	<xsl:for-each select="$linked_file//SMLCL:Regime">
            		<xsl:if test="$linked_file//SMLCL:Dynamics/@initial_regime=@name">
            			<xsl:value-of select="position()"/>
            		</xsl:if>
            	</xsl:for-each>
            </xsl:if>
            <xsl:if test="count($linked_file//SMLCL:Dynamics/@initial_regime)=0">1</xsl:if>);
            <xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regimeNext.resize(numEl_BRAHMS,0);

			for (int i_BRAHMS = 0; i_BRAHMS &lt; 3; ++i_BRAHMS) old_vals[i_BRAHMS] = 0;
			dt = 1000.0f * time->sampleRate.den / time->sampleRate.num; // time step in ms

<!---->
			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics">
				<xsl:apply-templates select="SMLCL:Regime" mode="defineTimeDerivFuncsPtr"/>
			</xsl:for-each>
<!---->

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:ImpulseReceivePort" mode="resizeReceive"/>
			</xsl:for-each>

		}

		// CREATE THE PORTS
		case EVENT_INIT_CONNECT:
		{
			Dims sizeDims_BRAHMS;
			for (int i_BRAHMS = 0; i_BRAHMS &lt; size_BRAHMS.size(); ++i_BRAHMS) {
				sizeDims_BRAHMS.push_back(size_BRAHMS[i_BRAHMS]);
			}
			//	on first call
			if (event->flags &amp; F_FIRST_CALL)
			{

<!---->
				<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
					<xsl:apply-templates select="SMLCL:AnalogSendPort" mode="createAnalogSendPorts"/>
				</xsl:for-each>

				<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
					<xsl:apply-templates select="SMLCL:ImpulseSendPort" mode="createImpulseSendPorts"/>
				</xsl:for-each>

				<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
					<xsl:apply-templates select="SMLCL:EventSendPort" mode="createEventSendPorts"/>
				</xsl:for-each>
<!---->

			}

			//	on last call
			if (event->flags &amp; F_LAST_CALL)
			{

				int numInputs_BRAHMS;
				Symbol set_BRAHMS;

				// create input ports
<!---->
				<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
					<xsl:apply-templates select="SMLCL:AnalogReceivePort" mode="createAnalogRecvPorts"/>
				</xsl:for-each>

				<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
					<xsl:apply-templates select="SMLCL:AnalogReducePort" mode="createAnalogReducePorts"/>
				</xsl:for-each>

				<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
					<xsl:apply-templates select="SMLCL:ImpulseReceivePort" mode="createImpulseRecvPorts"/>
				</xsl:for-each>

				<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
					<xsl:apply-templates select="SMLCL:EventReceivePort" mode="createEventRecvPorts"/>
				</xsl:for-each>

<!---->


			}

			// re-seed
			this-&gt;rngData_BRAHMS.seed = getTime();

			//	ok
			return C_OK;
		}

		case EVENT_RUN_SERVICE:
		{

			t = float(time->now)*dt;

			int num_BRAHMS;
			int numEl_BRAHMS = numElements_BRAHMS;

			<xsl:if test="count($linked_file//SMLCL:Regime)>1">
            for (int i_BRAHMS = 0; i_BRAHMS &lt; <xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime.size(); ++i_BRAHMS) {

            	<xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regimeNext[i_BRAHMS] = <xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[i_BRAHMS];

			}
			</xsl:if>


			// service inputs
<!---->

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:AnalogReceivePort | SMLCL:AnalogSendPort | SMLCL:AnalogReducePort" mode="serviceAnalogPorts"/>
			</xsl:for-each>

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:ImpulseReceivePort | SMLCL:ImpulseSendPort" mode="serviceImpulsePorts"/>
			</xsl:for-each>

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:EventReceivePort | SMLCL:EventSendPort" mode="serviceEventPorts"/>
			</xsl:for-each>

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:Dynamics" mode="doEventInputs"/>
			</xsl:for-each>

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:Dynamics" mode="doImpulseInputs"/>
			</xsl:for-each>

			<!---->

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:Dynamics" mode="doIter"/>
			</xsl:for-each>

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:Dynamics" mode="doTrans"/>
			</xsl:for-each>
<!---->

			// Apply regime changes and update logs
            for (int i_BRAHMS = 0; i_BRAHMS &lt; <xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime.size(); ++i_BRAHMS) {
            <xsl:if test="count($linked_file//SMLCL:Regime)>1">
           		<xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[i_BRAHMS] = <xsl:value-of select="concat(translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regimeNext[i_BRAHMS];
           	</xsl:if>

           		// updating logs...
           		<xsl:apply-templates select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogSendPort" mode="makeSendPortLogs"/>

			}

			// updating logs...
           	<xsl:apply-templates select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventSendPort" mode="makeSendPortLogs"/>

			// writing logs...
           	<xsl:apply-templates select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogSendPort" mode="saveSendPortLogs"/>

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:AnalogReceivePort | SMLCL:AnalogSendPort | SMLCL:AnalogReducePort" mode="outputAnalogPorts"/>
			</xsl:for-each>

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:EventReceivePort | SMLCL:EventSendPort" mode="outputEventPorts"/>
			</xsl:for-each>

			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass">
				<xsl:apply-templates select="SMLCL:ImpulseReceivePort | SMLCL:ImpulseSendPort" mode="outputImpulsePorts"/>
			</xsl:for-each>


			//	ok
			return C_OK;
		}

		case EVENT_RUN_STOP:
		{

			int numEl_BRAHMS = numElements_BRAHMS;
			t = float(time->now)*dt;

			<!-- WRITE XML FOR LOGS -->
			<xsl:apply-templates select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventSendPort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogSendPort" mode="finaliseLogs"/>
			<!-- Write out state variables -->
			<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics">
				<xsl:apply-templates select="SMLCL:StateVariable" mode="writeoutStateVariable"/>
			</xsl:for-each>

			return C_OK;
		}
	}

	//	if we service the event, we return C_OK
	//	if we don't, we should return S_NULL to indicate that we didn't
	return S_NULL;
}







//	include the second part of the overlay (it knows you've included it once already)
#include "brahms-1199.h"


</xsl:if>


</xsl:for-each>


</xsl:template>

<xsl:include href="SpineML_Dynamics.xsl"/>
<xsl:include href="SpineML_Regime.xsl"/>
<xsl:include href="SpineML_StateVariable.xsl"/>
<xsl:include href="SpineML_Parameter.xsl"/>
<xsl:include href="SpineML_AnalogPort.xsl"/>
<xsl:include href="SpineML_EventPort.xsl"/>
<xsl:include href="SpineML_ImpulsePort.xsl"/>

</xsl:stylesheet>


