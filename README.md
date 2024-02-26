# JOCN_Baror2024
This repository includes codes and scripts for analyses &amp; figure reproduction for the paper titled: Neural Mechanisms Determining the Duration of Task-free, Self-paced Visual Perception.

Content

Figures/
  
Figures were generated using R or Matlab codes.
  
Figures/R/
            
	Figures_script_R.R To generate R figures. 
	The folder contains analysis outputs required to plot R figures. 
	Outputs are named by figure number.

Figures/Matlab/
	    
	figures_matlab.m generates the Matlab figures.
	The folder contains analysis outputs required to plot the Matlab figures. 
	Outputs are named by figure number.
     
Analysis/

Behavioral, Eye-tracking, and EEG analysis are each located in a separate sub-folders.

Analysis/Behavioral/

* SP_regressingOutOrder.m runs to regress serial order from viewing duration
* SP_correlationsByOrder.m finds correlations between serial order and viewing duration
* SP_contentBasedViewingDuration.m examines whether image-specific content consistently influences viewing duration
* SP_luminanceAnalysis.m tests whether luminance accounts for viewing duration
  
Analysis/EEG/

Analysis/Eye Tracking/

Analysis/helpfulMats/

	The helpfulMats subfolder includes .mat files that are used in many of the analyses. These .mat files include:
 		* 
