install(FILES
  SpineML_2_BRAHMS_CL_neurons.xsl       SpineML_helpers.xsl
  SpineML_2_BRAHMS_CL_postsyn.xsl       SpineML_ImpulseOut.xsl
  SpineML_2_BRAHMS_CL_weight.xsl        SpineML_ImpulsePort.xsl
  SpineML_2_BRAHMS_EXPT.xsl             SpineML_Neuron_NL.xsl
  SpineML_2_BRAHMS_NL.xsl               SpineML_OnCondition.xsl
  SpineML_Alias.xsl                     SpineML_OnEvent.xsl
  SpineML_AnalogPort.xsl                SpineML_OnImpulse.xsl
  SpineML_ArrayConstantInput_NL.xsl     SpineML_Parameter.xsl
  SpineML_ArrayTimeVaryingInput_NL.xsl  SpineML_PostSynapse_NL.xsl
  SpineML_ConstantInput_NL.xsl          SpineML_ProjectionLinks_NL.xsl
  SpineML_Dynamics.xsl                  SpineML_Regime.xsl
  SpineML_EventOut.xsl                  SpineML_StateAssignment.xsl
  SpineML_EventPort.xsl                 SpineML_StateVariable.xsl
  SpineML_ExternalInput_NL.xsl          SpineML_TimeDerivative.xsl
  SpineML_ExternalOutput_NL.xsl         SpineML_TimeVaryingInput_NL.xsl
  SpineML_GenericInput_NL.xsl           SpineML_WeightUpdate_NL.xsl
  external_default.xsl
  DESTINATION ${DATA_DIR}/xsl/LL
  )
