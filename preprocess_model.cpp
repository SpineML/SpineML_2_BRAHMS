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

#include <fstream>
#include <string>
#include <sstream>
#include <iostream>

#include <string.h>

using namespace std;
using namespace rapidxml;

/*!
 * Read out model.xml file into a char*, allocating enough memory for
 * the task. Return the number of bytes allocated, or -1 on error.
 */
int alloc_and_read_xml_text (char* text);

/*
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
 * Do the work of replacing a KernelConnection with a ConnectionList
 */
void replace_kernel_connection (xml_node<> *syn_node,
                                const string& src_name,
                                const string& src_num,
                                const string& dst_population);

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
        text = (char*) realloc (text, curmem);
        // Restore textpos pointer in the reallocated memory:
        textpos = text + curpos;
        // copy line to textpos:
        strncpy (textpos, line.c_str(), llen);
        // Update current character position
        curpos += llen;
    }
    model.close();

    return curmem;
}

void preprocess_population (xml_node<> *pop_node)
{
    // Within each population:
    // Find source name; this is given by LL:Neuron name attribute; also have size attr.
    // search out projections.
    xml_node<> *neuron_node = root_node->first_node("LL:Neuron");
    if (!neuron_node) {
        // No src name. Does that mean we return or carry on?
        return;
    }

    string src_name("");
    xml_attribute<>* src_node;
    if ((src_node = neuron_node->first_attribute ("name"))) {
        src_name = src_node->value();
    } // else failed to get src name

    string src_num("");
    xml_attribute<>* src_num_node;
    if ((src_num_node = neuron_node->first_attribute ("name"))) {
        src_num = src_num_node->value();
    } // else failed to get src name

    // Now find all Projections.
    for (xml_node<> *proj_node = root_node->first_node("LL:Projection");
         proj_node;
         proj_node = proj_node->next_sibling("LL:Projection")) {

        preprocess_projection (proj_node, src_name, src_num);
    }
}

void preprocess_projection (xml_node<> *proj_node,
                            const string& src_name,
                            const string& src_num)
{
    // Get the destination.
    string dst_population("");
    xml_attribute<>* dst_pop_node;
    if ((dst_pop_node = neuron_node->first_attribute ("dst_population"))) {
        dst_population = dst_pop_node->value();
    } // else failed to get src name

    // And then for each synapse in the projection:
    for (xml_node<> *syn_node = proj_node->first_node("LL:Synapse");
         syn_node;
         syn_node = syn_node->next_sibling("LL:Synapse")) {
        preprocess_synapse (syn_node, src_name, src_num, dst_population);
    }
}

void preprocess_synapse (xml_node<> *syn_node,
                         const string& src_name,
                         const string& src_num,
                         const string& dst_population)
{
    // For each synapse... Is there a KernelConnection?
    xml_node<>* kernel_connection = syn_node->first_node("KernelConnection");
    if (!kernel_connection) {
        return;
    }
    replace_kernel_connection (kernel_connection, src_name, src_num, dst_population);
    // Plus any other modifications which need to be made...
}

/*
Take this:
    <KernelConnection>
       <Kernel scale="1" size="3">
         <KernelRow col0="1" col1="0" col2="0"/>
         <KernelRow col0="1" col1="0" col2="1"/>
         <KernelRow col0="0" col1="1" col2="1"/>
       </Kernel>
       <Delay Dimension="ms"/>
    </KernelConnection>

And replace with something like this:

    <ConnectionList>
      <BinaryFile file_name="C56f0fcdc-bbf7-412b-867d-49f4698edc00.bin" num_connections="432" explicit_delay_flag="0"/>
      <Delay Dimension="ms">
        <FixedValue value="0"/>
      </Delay>
    </ConnectionList>

    Copy what kernel_connection::generate_connections does in SpineCreator.
*/
void replace_kernel_connection (xml_node<> *syn_node,
                                const string& src_name,
                                const string& src_num,
                                const string& dst_population)
{
    // Seems like we need this layout stuff... Need the physical layout of the neurons.

    // in the origin code, src is a pointer to a population. I guess
    // this actually generates some default physical layout.
    src->layoutType->generateLayout(src->numNeurons,&src->layoutType->locations,errorLog);
    if (!errorLog.isEmpty()) {
        return;
    }
    dst->layoutType->generateLayout(dst->numNeurons,&dst->layoutType->locations,errorLog);
    if (!errorLog.isEmpty()) {
        return;
    }

    // Needs converting
    int srcNum = src_num;

    float total_ops = (float)srcNum;
    int scale_val = round(100000000.0/(srcNum*dstNum));
    int oldprogress = 0;

    for (int i = 0; i < srcNum; ++i) {
        for (int j = 0; j < dstNum; ++j) {

            // CALCULATE (kernels ignore z component for now!)
            float xRaw = dst->layoutType->locations[j].x - src->layoutType->locations[i].x;
            float yRaw = dst->layoutType->locations[j].y - src->layoutType->locations[i].y;

            // rotate:
            float x;
            float y;
            if (rotation != 0) {
                x = cos(rotation)*xRaw - sin(rotation)*yRaw;
                y = sin(rotation)*xRaw + cos(rotation)*yRaw;
            } else {
                x = xRaw;
                y = yRaw;
            }

            // if we are outside the kernel
            if (fabs(x) > floor(kernel_size/2.0) * kernel_scale || \
                    fabs(y) > floor(kernel_size/2.0) * kernel_scale)
                continue;

            // otherwise find the right kernel box
            int boxX = floor(x / kernel_scale + 0.5) + floor(kernel_size/2.0);
            int boxY = floor(y / kernel_scale + 0.5) + floor(kernel_size/2.0);

            // add connection based on kernel
            if (float(rand())/float(RAND_MAX) < kernel[boxX][boxY]) {
                mutex->lock();
                conn newConn;
                newConn.src = i;
                newConn.dst = j;
                conns->push_back(newConn);
                mutex->unlock();
            }
        }
        if (round(float(i)/total_ops * 100.0) > oldprogress) {
            emit progress((int) round(float(i)/total_ops * 100.0));
            oldprogress = round(float(i)/total_ops * 100.0)+scale_val;
        }
    }
    this->moveToThread(QApplication::instance()->thread());
    emit connectionsDone();
}

int main()
{
    char* text = static_cast<char*>(0);
    if (alloc_and_read_xml_text (text)) {
        return -1;
    }
    xml_document<> doc;    // character type defaults to char

    // we are choosing to parse the XML declaration
    // parse_no_data_nodes prevents RapidXML from using the somewhat surprising
    // behavior of having both values and data nodes, and having data nodes take
    // precedence over values when printing
    // >>> note that this will skip parsing of CDATA nodes <<<
    doc.parse<parse_declaration_node | parse_no_data_nodes>(text);

    if (doc.first_node()->first_attribute("encoding")) {
        string encoding = doc.first_node()->first_attribute("encoding")->value();
        cout << "encoding: " << encoding << endl;
    }

    // Get the root node.
    xml_node<>* root_node = doc.first_node("LL:SpineML");
    if (!root_node) {
        // Possibly look for HL:SpineML, if we have a high level model (not
        // used by anyone at present).
        cout << "No root node LL:SpineML!" << endl;
        free (text);
        return -1;
    }

    // Search each population for stuff.
    for (xml_node<> *pop_node = root_node->first_node("LL:Population");
         pop_node;
         pop_node = pop_node->next_sibling("LL:Population")) {
        preprocess_population (pop_node);
    }

    // Clean up and return.
    free (text);
    return 0;
}
