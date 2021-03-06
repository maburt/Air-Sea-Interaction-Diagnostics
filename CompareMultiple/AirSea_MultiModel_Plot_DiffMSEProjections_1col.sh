#!/bin/csh

# =============================================================================
# This code reads output generated by airsea_diagnostics_DB.csh as applied
# to several different models or experiments.
#
# It plots mean fields in a single column using uniform contour intervals.
#
# A maximum of 8 panels is allowed.  For more panels, see 
#	AirSea_MultiModel_Plot_Means_2col.sh
#
# The model cases can be arranged any way the user choses, but it is envisioned
# that the first case be either OBS/reanalysis, or a control run.  Subsequent
# cases would then be results from different models or experiments. 
#
# Environmental variable "modelname" must match one of those listed in
# airsea_definitions_DB.sh
#
# The user specifies the output directory with the "setenv dirp" commend
# =============================================================================

setenv 	nCases			3		# requires one block per case, below
setenv	nRows			4		# to force panels to have a given size
setenv	dirp			"/Users/demott/Projects/MC_Experiments/"		
setenv	panelLabStrt	0		# adjust panel labeling:  0=a, 1=b, 2=c, etc.
setenv	u850_overlay	False	# True or False
setenv	ColumnTitle		False	# to enable or suppress column title

foreach var	( Vlw Vsw LHFLX SHFLX Vm_hadv Vudmdx Vvdmdy Vomegadmdp )
#foreach var	( Vlw )

	setenv varName $var

	#----- case 0 ; 0-based indexing used in NCL, so we'll stick with that
	setenv 	diffname SPCAM4-flatisland_minus_SPCAM4-ctrl
	set 	modelname=`echo $diffname | cut -d _ -f1`
	#echo 	$modelname
	source 	../airsea_definitions_DB.sh # handle model-specific logic
	setenv	caseName0	$modelname
	#echo 	$caseName0
	setenv 	MODDIR0		$FILEDIR"/proc/"$diffname"/"
	#echo	$MODDIR0
	setenv 	MODNAME0	$diffname
	#echo	$MODNAME0
	
	#----- case 1 
	setenv 	diffname SPCAM4-noland_minus_SPCAM4-ctrl
	set 	modelname=`echo $diffname | cut -d _ -f1`
	#echo 	$modelname
	source 	../airsea_definitions_DB.sh # handle model-specific logic
	setenv	caseName1	$modelname
	#echo 	$caseName1
	setenv 	MODDIR1		$FILEDIR"/proc/"$diffname"/"
	#echo	$MODDIR1
	setenv 	MODNAME1	$diffname
	#echo	$MODNAME1
	
	#----- case 2 
	setenv 	diffname SPCAM4-nodc-landfrac30_minus_SPCAM4-ctrl
	set 	modelname=`echo $diffname | cut -d _ -f1`
	#echo 	$modelname
	source 	../airsea_definitions_DB.sh # handle model-specific logic
	setenv	caseName2	$modelname
	#echo 	$caseName2
	setenv 	MODDIR2		$FILEDIR"/proc/"$diffname"/"
	#echo	$MODDIR2
	setenv 	MODNAME2	$diffname
	#echo	$MODNAME2
		
	
	ncl -Q ./plot_MultiModel_DiffMSEProjections_1col.ncl

end

