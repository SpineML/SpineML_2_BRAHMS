/*
 * This program parses the SpineML model, updating any aspects of the
 * model where parameters, weights or connectivity are specified in
 * meta-form. For example, where connections are given in kernel form,
 * this program creates a connection list file and modifies the
 * <KernelConnection> xml element into a <ConnectionList> element with
 * an associated binary connection list file.
 *
 * The original model.xml file is renamed model_orig.xml and a new
 * model.xml file is written out containing the new, specific
 * information.
 *
 * The dependency-free rapidxml header-only xml parser is used to
 * read, modify and write out model.xml.
 *
 * Author: Seb James, 2014.
 */

#include "rapidxml.hpp"
#include "rapidxml_print.hpp"
#include "include/rng.h"
#include <fstream>
#include <string>
#include <sstream>
#include <iostream>
#include <vector>
#include <stdexcept>
#include <unistd.h>
#include <string.h>

using namespace std;
using namespace rapidxml;

/*!
 * It may be that we need to run this for HL and LL models.
 */
#define LVL "LL:"

/*!
 * A global for the first population node pointer. I anticipate this
 * going into a class at some point, hence just sticking it in as a
 * global for now.
 */
xml_node<> * first_pop_node;

/*!
 * A global for the root node pointer. Same comments apply as for
 * first_pop_node.
 */
xml_node<> * root_node;

/*!
 * A cartesian location structure. This is a copy of the same struct
 * found in SpineCreator/globalHeader.h.
 */
struct loc {
    float x;
    float y;
    float z;
};

/*!
 * A connection structure, to hold information about a connection from
 * one neuron body to another. This is a copy of the same struct found
 * in SpineCreator/globalHeader.h.
 */
struct conn {
    int src;
    int dst;
    float metric;
};

/*!
 * Read out model.xml file into a char*, allocating enough memory for
 * the task. Return the number of bytes allocated, or -1 on error.
 */
int alloc_and_read_xml_text (char* text);

/*!
 * Find the number of neurons in the destination population, starting
 * from the root node or the first population node (globals/members).
 */
int find_num_neurons (const string& dst_population);

/*!
 * Take a population node, and process this for any changes we need to
 * make. Sub-calls preprocess_projection.
 */
void preprocess_population (xml_node<>* pop_node);

/*!
 * Process the passed-in projection, making any changes necessary.
 */
void preprocess_projection (xml_node<>* proj_node,
                            const string& src_name, const string& src_num);

/*!
 * Process the synapse. Search for KernelConnection and modify if found.
 */
void preprocess_synapse (xml_node<>* proj_node,
                         const string& src_name, const string& src_num,
                         const string& dst_population);

/*!
 * Do the work of replacing a FixedProbability connection with a
 * ConnectionList
 *
 * Go from this:
 *          <LL:Synapse>
 *               <FixedProbabilityConnection probability="0.11" seed="123">
 *                   <Delay Dimension="ms">
 *                       <FixedValue value="0.2"/>
 *                   </Delay>
 *               </FixedProbabilityConnection>
 *
 * to this:
 *
 * (an explicit list of connections, with distribution generated like the
 * code in SpineML_2_BRAHMS_CL_weight.xsl)
 */
void replace_fixedprob_connection (xml_node<> *syn_node,
                                   const string& src_name,
                                   const string& src_num,
                                   const string& dst_population);

/*!
 * Global function implementations
 */
//@{
int alloc_and_read_xml_text (char* text)
{
    char* textpos = text;
    string line("");

    ifstream model;
    model.open ("./model/model.xml", ios::in);
    if (!model.is_open()) {
        cerr << "model.xml could not be opened." << endl;
        return -1;
    }

    size_t curmem = 0; // current allocated memory count (chars)
    size_t llen = 0;   // line length (chars)
    size_t curpos = 0;
    while (getline (model, line)) {
        // Restore the newline
        line += "\n";
        // Allocate enough memory in char* text for this line
        llen = line.size();
        curmem += llen;

        // This attempt to dynamically realloc mucks things
        // up. probably need to pass a char** if I want to do this.
        //
        // cout << "realloc " << curmem << " bytes for text." << endl;
        // text = (char*) realloc (text, curmem);

        // Restore textpos pointer in the reallocated memory:
        textpos = text + curpos;
        // copy line to textpos:
        strncpy (textpos, line.c_str(), llen);
        // Update current character position
        curpos += llen;
    }
    model.close();

    // Note: text is already null terminated
    return curmem;
}

int find_num_neurons (const string& dst_population)
{
    cout << __FUNCTION__ << " called for dst_population: "<< dst_population << endl;
    int numNeurons = -1;
    xml_node<>* pop_node = first_pop_node->next_sibling(LVL"Population");
    xml_node<>* neuron_node;
    while (pop_node) {
        // Dive into this population:
        // <LL:Population>
        //    <LL:Neuron name="Population 0" size="10" url="New_Component_1.xml">
        neuron_node = pop_node->first_node(LVL"Neuron");
        if (neuron_node) {
            // Find name.
            string name("");
            xml_attribute<>* name_attr;
            if ((name_attr = neuron_node->first_attribute ("name"))) {
                name = neuron_node->value();
                cout << "name: " << name << endl; // always empty!
                usleep (100000);
                if (name == dst_population) {
                    // Match! Get the size:
                    xml_attribute<>* size_attr;
                    if ((size_attr = neuron_node->first_attribute ("size"))) {
                        stringstream ss;
                        ss << neuron_node->value();
                        ss >> numNeurons;
                        break;
                    } // else failed to get size attr of Neuron node
                } // else no match, move on.
            } // else failed to get name attr
        } // else no neuron node.
        else {
            cout << "No neuron node here..." << endl;
        }
        pop_node = first_pop_node->next_sibling(LVL"Population");
    }
    return numNeurons;
}

void preprocess_population (xml_node<> *pop_node)
{
    // Within each population:
    // Find source name; this is given by LL:Neuron name attribute; also have size attr.
    // search out projections.
    xml_node<> *neuron_node = pop_node->first_node(LVL"Neuron");
    if (!neuron_node) {
        // No src name. Does that mean we return or carry on?
        return;
    }

    string src_name("");
    xml_attribute<>* name_attr;
    if ((name_attr = neuron_node->first_attribute ("name"))) {
        src_name = name_attr->value();
    } // else failed to get src name

    string src_num("");
    xml_attribute<>* num_attr;
    if ((num_attr = neuron_node->first_attribute ("size"))) {
        src_num = num_attr->value();
    } // else failed to get src num

    // Now find all Projections.
    for (xml_node<> *proj_node = pop_node->first_node(LVL"Projection");
         proj_node;
         proj_node = proj_node->next_sibling(LVL"Projection")) {

        preprocess_projection (proj_node, src_name, src_num);
    }
}

void preprocess_projection (xml_node<> *proj_node,
                            const string& src_name,
                            const string& src_num)
{
    cout << __FUNCTION__ << " called" << endl;
    // Get the destination.
    string dst_population("");
    xml_attribute<>* dst_pop_attr;
    if ((dst_pop_attr = proj_node->first_attribute ("dst_population"))) {
        dst_population = dst_pop_attr->value();
    } // else failed to get src name

    // And then for each synapse in the projection:
    for (xml_node<> *syn_node = proj_node->first_node(LVL"Synapse");
         syn_node;
         syn_node = syn_node->next_sibling(LVL"Synapse")) {
        preprocess_synapse (syn_node, src_name, src_num, dst_population);
    }
}

void preprocess_synapse (xml_node<> *syn_node,
                         const string& src_name,
                         const string& src_num,
                         const string& dst_population)
{
    cout << __FUNCTION__ << " called" << endl;
    // For each synapse... Is there a FixedProbability?
    xml_node<>* fixedprob_connection = syn_node->first_node("FixedProbabilityConnection");
    if (!fixedprob_connection) {
        return;
    }
    replace_fixedprob_connection (fixedprob_connection, src_name, src_num, dst_population);
    // Plus any other modifications which need to be made...
}

void replace_fixedprob_connection (xml_node<> *fixedprob_node,
                                   const string& src_name,
                                   const string& src_num,
                                   const string& dst_population)
{
    cout << __FUNCTION__ << " called" << endl;

    // create the lookups for the connectivity
    vector <vector <int> > connectivityS2C;
    vector <vector <int> > connectivityD2C;
    vector <int> connectivityC2S;
    vector <int> connectivityC2D;

    // All the rng data used in rng.h
    RngData rngData;

    // Get the FixedProbability probabilty and seed from this bit of the model.xml:
    // <FixedProbabilityConnection probability="0.11" seed="123">
    float probabilityValue = 0;
    {
        string fp_probability("");
        xml_attribute<>* fp_probability_attr;
        if ((fp_probability_attr = fixedprob_node->first_attribute ("probability"))) {
            fp_probability = fp_probability_attr->value();
        } else {
            // failed to get probability; can't proceed.
            throw runtime_error ("Failed to get FixedProbability's probability attr from model.xml");
        }
        stringstream ss;
        ss << fp_probability;
        ss >> probabilityValue;
    }

    int seed = 0;
    {
        string fp_seed("");
        xml_attribute<>* fp_seed_attr;
        if ((fp_seed_attr = fixedprob_node->first_attribute ("seed"))) {
            fp_seed = fp_seed_attr->value();
        } else {
            // failed to get seed; can't proceed.
            throw runtime_error ("Failed to get FixedProbability's seed attr from model.xml");
        }
        stringstream ss;
        ss << fp_seed;
        ss >> seed;
    }

    unsigned int srcNum = 0;
    {
        stringstream ss;
        ss << src_num;
        ss >> srcNum;
    }

    cout << "probability: " << probabilityValue << ", seed: " << seed
         << ", srcNum: " << srcNum << endl;

    // Find the number of neurons in the destination population
    int dstNum = find_num_neurons (dst_population);

    // seed the rng: 2 questions about origin code. Why the additional
    // 1 in front of the seed in 2nd arg to zigset, and why was
    // rngData.seed hardcoded to 123?
    zigset (&rngData, /*1*/seed);
    rngData.seed = seed; // or 123??

    // run through connections, creating connectivity pattern:
    connectivityC2D.reserve (dstNum); // probably num from dst_population
    connectivityS2C.resize (srcNum); // probably src_num.

    for (unsigned int i = 0; i < connectivityS2C.size(); ++i) {
        connectivityS2C[i].reserve((int) round(dstNum*probabilityValue));
    }
    for (unsigned int srcIndex = 0; srcIndex < srcNum; ++srcIndex) {
        for (unsigned int dstIndex = 0; dstIndex < dstNum; ++dstIndex) {
            if (UNI(&rngData) < probabilityValue) {
                connectivityC2D.push_back(dstIndex);
                connectivityS2C[srcIndex].push_back(connectivityC2D.size()-1);
            }

        }
        if (float(connectivityC2D.size()) > 0.9*float(connectivityC2D.capacity())) {
            connectivityC2D.reserve(connectivityC2D.capacity()+dstNum);
        }
    }

    // set up the number of connections
    int numConn = connectivityC2D.size();

    // Ok, having made up the connectivity maps as above, write them
    // out into a connection binary file.
    cout << "numConn is " << numConn << endl;
}
//@} End global function implementations

int main()
{
    char* text = static_cast<char*>(0);
    text = (char*) malloc (1000000*sizeof(char)); // FIXME, need better scheme here.
    // Currently, alloc_and_read_xml_text just does read_xml_text.
    if (!alloc_and_read_xml_text (text)) {
        cerr << "Failed to read" << endl;
        return -1;
    }

    if (text) {
        // OK.
        // cout << "text = " << text << endl;
    } else {
        cerr << "No text!" << endl;
        return -1;
    }

    xml_document<> doc;    // character type defaults to char

    // we are choosing to parse the XML declaration
    // parse_no_data_nodes prevents RapidXML from using the somewhat surprising
    // behavior of having both values and data nodes, and having data nodes take
    // precedence over values when printing
    // >>> note that this will skip parsing of CDATA nodes <<<
    cout << "about to doc.parse.." << endl;
    doc.parse<parse_declaration_node | parse_no_data_nodes>(text);
    cout << "doc.parse worked" << endl;

    if (doc.first_node()->first_attribute("encoding")) {
        string encoding = doc.first_node()->first_attribute("encoding")->value();
        cout << "encoding: " << encoding << endl;
    }

    // Get the root node.
    root_node = doc.first_node(LVL"SpineML");
    if (!root_node) {
        // Possibly look for HL:SpineML, if we have a high level model (not
        // used by anyone at present).
        cout << "No root node LL:SpineML!" << endl;
        free (text);
        return -1;
    }

    // Search each population for stuff.
    for (first_pop_node = root_node->first_node(LVL"Population");
         first_pop_node;
         first_pop_node = first_pop_node->next_sibling(LVL"Population")) {
        cout << "preprocess_population" << endl;
        preprocess_population (first_pop_node);
    }

    // Clean up and return.
    free (text);
    return 0;
}
