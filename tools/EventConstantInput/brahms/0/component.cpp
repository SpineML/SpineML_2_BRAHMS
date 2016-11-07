/*
  Autogenerated BRAHMS process from 9ML description.
  Engine: XSLT
  Engine Author: Alex Cope 2012
  Node name:
*/

#define COMPONENT_CLASS_STRING "dev/SpineML/tools/EventConstantInput"
#define COMPONENT_CLASS_CPP dev_spineml_tools_eventconstantinput_0
#define COMPONENT_RELEASE 0
#define COMPONENT_REVISION 1
#define COMPONENT_ADDITIONAL "Author=SpineML_2_BRAHMS\n" "URL=Not supplied\n"
#define COMPONENT_FLAGS (F_NOT_RATE_CHANGER)

#define OVERLAY_QUICKSTART_PROCESS

// include the component interface overlay (component bindings 1199)
#include "brahms-1199.h"

#include "rng.h"

// alias data and util namespaces to something briefer
namespace numeric = std_2009_data_numeric_0;
namespace spikes = std_2009_data_spikes_0;
namespace rng = std_2009_util_rng_0;

using namespace std;

class COMPONENT_CLASS_CPP;

enum rateType {
    Poisson,
    Regular
};

//////////////// COMPONENT CLASS (DERIVES FROM Process)

class COMPONENT_CLASS_CPP : public Process
{

public:

    // use ctor/dtor only if required
    COMPONENT_CLASS_CPP() {}
    ~COMPONENT_CLASS_CPP() {}

    // the framework event function
    Symbol event(Event* event);

private:

    // We have to create (and manage) the volatile data for rng.h here.
    RngData rngData;

    // Analog Ports

    spikes::Output out;

    int size;

    VDOUBLE values;

    VDOUBLE nextSpike;

    vector < float > logT;
    vector < int > logIndex;
    vector < int > logMap;
    FILE * logFile;

    string baseNameForLogs;

    bool logOn;
    bool logAll;

    rateType type;

    int rateSeed;

    float dt;
};

//////////////// EVENT

Symbol COMPONENT_CLASS_CPP::event(Event* event)
{
    switch(event->type)
    {
    case EVENT_STATE_SET:
    {
        // extract DataML
        EventStateSet* data = (EventStateSet*) event->data;
        XMLNode xmlNode(data->state);
        DataMLNode nodeState(&xmlNode);

        // Initialise volatile data variables for rng.h (but no need for zigset() here)
        rngDataInit (&rngData);
        rateSeed = nodeState.getField("rateSeed").getUINT32();
        if (rateSeed == 0) {
            this->rngData.seed = getTime();
        } else {
            this->rngData.seed = rateSeed;
        }

        // obtain the parameters
        values = nodeState.getField("values").getArrayDOUBLE();

        size = nodeState.getField("size").getUINT32();

        if (!(values.size() == 1 || values.size() == (unsigned int)size)) {
            // bad data
            berr << "Error: incorrect number of values for Event Constant Input";
        }

        type = (rateType) nodeState.getField("rateType").getUINT32();

        // Log base name
        baseNameForLogs = "../log/" + nodeState.getField("logfileNameForComponent").getSTRING();

        logOn = false;

        // check for logs
        if (nodeState.hasField("spikeLOG")) {
            logOn = true;
            // we have a log! Read the data in:
            VDOUBLE tempLogData = nodeState.getField("spikeLOG").getArrayDOUBLE();
            // logmap resize
            logMap.resize(size,-1);
            // set the logmap values - checking for out of range values
            for (unsigned int i = 0; i < tempLogData.size(); ++i) {
                if (tempLogData[i]+0.5 >size) {
                    bout << "Attempting to log an index out of range" << D_WARN;
                } else {
                    // set in mapping that the ith log value relates to the tempLogData[i]th neuron
                    logMap[(int) tempLogData[i]] = i;
                }
            }
            // open the logfile for writing
            string logFileName = baseNameForLogs;
            logFileName.append("_spike_log.csv");
            logFile = fopen(logFileName.c_str(),"w");
        }

        if (nodeState.hasField("spikeLOGALL")) {
            logAll = true;
            logOn = true;

            // open the logfile for writing
            string logFileName = baseNameForLogs;
            logFileName.append("_spike_log.csv");
            logFile = fopen(logFileName.c_str(),"w");
        } else {
            logAll = false;
        }

        nextSpike.resize(size);

        if (values.size() == 1) {
            for (UINT32 i = 0; i < (UINT32)size; ++i) {
                if (type == Poisson) {
                    nextSpike[i] =  1000.0*log(1.0-UNI(&this->rngData))/-values[0];
                } else if (type == Regular) {
                    nextSpike[i] = 1000.0/values[0];
                }
            }
        } else {
            for (UINT32 i = 0; i < values.size(); ++i) {
                if (type == Poisson) {
                    nextSpike[i] = 1000.0*log(1.0-UNI(&this->rngData))/-values[i];
                } else if (type == Regular) {
                    nextSpike[i] = 1000.0/values[i];
                }
            }
        }

        dt = 1000.0f * time->sampleRate.den / time->sampleRate.num; // time step in ms

        return C_OK;
    }

    // CREATE THE PORTS
    case EVENT_INIT_CONNECT:
    {
        // on first call
        if (event->flags & F_FIRST_CALL) {
            out.setName("out");
            out.create(hComponent);
            out.setCapacity(size);
        }

        // on last call
        if (event->flags & F_LAST_CALL)
        {
        }

        return C_OK;
    }

    case EVENT_RUN_SERVICE:
    {
        float t = float(time->now)*dt;

        vector < int > spikes;

        if (values.size() == 1) {
            for (UINT32 i = 0; i < (UINT32)size; ++i) {
                if (nextSpike[i] <= t) {
                    spikes.push_back(i);
                    if (logOn) {
                        if (logAll || logMap[i] != -1) {
                            logT.push_back(t);
                            logIndex.push_back(i);
                        }
                    }
                    if (type == Poisson) {
                        nextSpike[i] = t + 1000.0*log(1.0-UNI(&this->rngData))/-values[0];
                    } else if (type == Regular) {
                        nextSpike[i] = t + 1000.0/values[0];
                    }
                }
            }
        } else {
            for (UINT32 i = 0; i < values.size(); ++i) {
                if (nextSpike[i] <= t) {
                    spikes.push_back(i);
                    if (logOn) {
                        if (logAll || logMap[i] != -1) {
                            logT.push_back(t);
                            logIndex.push_back(i);
                        }
                    }
                    if (type == Poisson) {
                        nextSpike[i] = t + 1000.0*log(1.0-UNI(&this->rngData))/-values[i];
                    } else if (type == Regular) {
                        nextSpike[i] = t + 1000.0/values[i];
                    }
                }
            }
        }

        if (logOn && logIndex.size() > 100000) {
            for (unsigned int i = 0; i < logIndex.size(); i++) {
                fprintf(logFile, "%f, %d\n", logT[i],logIndex[i]);
            }
            logT.clear();
            logIndex.clear();
        }

        out.setContent(&(spikes[0]), spikes.size());

        return C_OK;
    }

    case EVENT_RUN_STOP:
    {
        float t = float(time->now)*dt;
        if (logOn) {
            for (unsigned int i = 0; i < logIndex.size(); i++) {
                fprintf(logFile, "%f, %d\n", logT[i],logIndex[i]);
            }
            FILE * logRep;
            string logFileName = baseNameForLogs;
            logFileName.append("_spike_logrep.xml");
            logRep = fopen(logFileName.c_str(),"w");
            logFileName = baseNameForLogs;
            logFileName.append("_spike_log.csv");
            fprintf(logRep, "<LogReport>\n");
            fprintf(logRep, " <EventLog>\n");
            fprintf(logRep, "  <LogFile>%s</LogFile>\n",logFileName.c_str());
            fprintf(logRep, "  <LogFileType>csv</LogFileType>\n");
            fprintf(logRep, "  <LogPort>spike</LogPort>\n");
            fprintf(logRep, "  <LogEndTime>%f</LogEndTime>\n",t);
            if (!logAll) {
                for (unsigned int i = 0; i < logMap.size(); ++i) {
                    if (logMap[i] > -0.1) {
                        fprintf(logRep,"  <LogIndex>%d</LogIndex>\n",i);
                    }
                }
            } else {
                fprintf(logRep, "  <LogAll size=\"%d\" type=\"int\" dims=\"\"/>\n",size);
            }
            fprintf(logRep,"  <LogCol heading=\"t\" dims=\"ms\" type=\"double\"/>\n");
            fprintf(logRep,"  <LogCol heading=\"index\" dims=\"\" type=\"int\"/>\n");
            fprintf(logRep, " </EventLog>\n");
            fprintf(logRep, "</LogReport>\n");

            fclose(logRep);
            fclose(logFile);
        }

        return C_OK;
    }
    }

    // if we service the event, we return C_OK
    // if we don't, we should return S_NULL to indicate that we didn't
    return S_NULL;
}

// include the second part of the overlay (it knows you've included it once already)
#include "brahms-1199.h"
