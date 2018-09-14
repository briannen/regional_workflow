#!/bin/bash
#
#----THEIA JOBCARD
#
# Note that the following PBS directives do not have any effect if this
# script is called via an interactive TORQUE/PBS job (i.e. using the -I 
# flag to qsub along with the -x flag to specify this script).  The fol-
# lowing directives are placed here in case this script is called as a 
# batch (i.e. non-interactive) job.
#
#PBS -N stage
#PBS -A gsd-fv3
#PBS -o out.$PBS_JOBNAME.$PBS_JOBID
#PBS -e err.$PBS_JOBNAME.$PBS_JOBID
#PBS -l nodes=1:ppn=1
#PBS -q batch
#PBS -l walltime=0:30:00
#PBS -W umask=022

############################################
# Staging script to set up FV3 run directory
############################################

#Source variables from user-defined file
. ${BASEDIR}/fv3gfs/ush/setup_grid_orog_ICs_BCs.sh


#Define template namelist/configure file location
templates="${BASEDIR}/fv3gfs/ush/templates"

#Define fixed file location
fix_files=${FIXgsm}

#Define run directory
RUNDIR="${BASEDIR}/run_dirs/${subdir_name}"

#
# Check if the run directory already exists.  If so, don't delete it in 
# case it contains needed information.  Instead, rename it to it origi-
# nal name followed by "_oldNNN", where NNN is a 3-digit integer.
#
if [ -d $RUNDIR ]; then

  i=1
  old_indx=$( printf "%03d" "$i" )
  RUNDIR_OLD=${RUNDIR}_old${old_indx}
  while [ -d ${RUNDIR_OLD} ]; do
    i=$[$i+1]
    old_indx=$( printf "%03d" "$i" )
    RUNDIR_OLD=${RUNDIR}_old${old_indx}
  done

  echo
  echo "Run directory already exists:"
  echo
  echo "  RUNDIR = \"$RUNDIR\""
  echo
  echo "Renaming preexisting run directory to:"
  echo
  echo "  RUNDIR_OLD = \"$RUNDIR_OLD\""
  echo
  mv $RUNDIR $RUNDIR_OLD

fi
#
# Create the run directory.  Note that at this point, we are guaranteed
# that RUNDIR doesn't already exist.
#
mkdir -p $RUNDIR

#Copy all namelist and configure file templates to the run directory
echo "Copying necessary namelist and configure file templates to the run directory..."
cp ${templates}/input.nml ${RUNDIR}
cp ${templates}/model_configure ${RUNDIR}
cp ${templates}/diag_table ${RUNDIR}
cp ${templates}/field_table ${RUNDIR}
cp ${templates}/nems.configure ${RUNDIR}
cp ${templates}/run.regional ${RUNDIR}/run.regional
cp ${templates}/data_table ${RUNDIR}

#Place all fixed files into run directory
echo "Copying necessary fixed files into the run directory..."
cp ${fix_files}/CFSR.SEAICE.1982.2012.monthly.clim.grb ${RUNDIR}
cp ${fix_files}/RTGSST.1982.2012.monthly.clim.grb ${RUNDIR}
cp ${fix_files}/seaice_newland.grb ${RUNDIR}
cp ${fix_files}/global_climaeropac_global.txt ${RUNDIR}/aerosol.dat
cp ${fix_files}/global_albedo4.1x1.grb ${RUNDIR}
cp ${fix_files}/global_glacier.2x2.grb ${RUNDIR}
cp ${fix_files}/global_h2o_pltc.f77 ${RUNDIR}/global_h2oprdlos.f77
cp ${fix_files}/global_maxice.2x2.grb ${RUNDIR}
cp ${fix_files}/global_mxsnoalb.uariz.t126.384.190.rg.grb ${RUNDIR}
cp ${fix_files}/global_o3prdlos.f77 ${RUNDIR}
cp ${fix_files}/global_shdmax.0.144x0.144.grb ${RUNDIR}
cp ${fix_files}/global_shdmin.0.144x0.144.grb ${RUNDIR}
cp ${fix_files}/global_slope.1x1.grb ${RUNDIR}
cp ${fix_files}/global_snoclim.1.875.grb ${RUNDIR}
cp ${fix_files}/global_snowfree_albedo.bosu.t126.384.190.rg.grb ${RUNDIR}
cp ${fix_files}/global_soilmgldas.t126.384.190.grb ${RUNDIR}
cp ${fix_files}/global_soiltype.statsgo.t126.384.190.rg.grb ${RUNDIR}
cp ${fix_files}/global_tg3clim.2.6x1.5.grb ${RUNDIR}
cp ${fix_files}/global_vegfrac.0.144.decpercent.grb ${RUNDIR}
cp ${fix_files}/global_vegtype.igbp.t126.384.190.rg.grb ${RUNDIR}
cp ${fix_files}/global_zorclim.1x1.grb ${RUNDIR}
cp ${fix_files}/global_sfc_emissivity_idx.txt ${RUNDIR}/sfc_emissivity_idx.txt
cp ${fix_files}/global_solarconstant_noaa_an.txt ${RUNDIR}/solarconstant_noaa_an.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2010.txt ${RUNDIR}/co2historicaldata_2010.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2011.txt ${RUNDIR}/co2historicaldata_2011.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2012.txt ${RUNDIR}/co2historicaldata_2012.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2013.txt ${RUNDIR}/co2historicaldata_2013.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2014.txt ${RUNDIR}/co2historicaldata_2014.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2015.txt ${RUNDIR}/co2historicaldata_2015.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2016.txt ${RUNDIR}/co2historicaldata_2016.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2017.txt ${RUNDIR}/co2historicaldata_2017.txt
cp ${fix_files}/fix_co2_proj/global_co2historicaldata_2018.txt ${RUNDIR}/co2historicaldata_2018.txt
cp ${fix_files}/global_co2historicaldata_glob.txt ${RUNDIR}/co2historicaldata_glob.txt
cp ${fix_files}/co2monthlycyc.txt ${RUNDIR}

#Check to make sure FV3 executable exists and copy to run directory
if [ ! -f $BASEDIR/NEMSfv3gfs/tests/fv3_32bit.exe ]; then
   echo "FV3 executable does not exist, please compile first.  Exiting..."
   exit 1
else
   echo "Copying FV3 executable to run directory..."
   cp $BASEDIR/NEMSfv3gfs/tests/fv3_32bit.exe $RUNDIR/fv3_gfs.x
fi


#Make INPUT directory within the run directory if it doesn't already exist
if [ ! -d $RUNDIR/INPUT ]; then
   echo "Making $RUNDIR/INPUT..."
   mkdir $RUNDIR/INPUT
else
   echo "Removing and recreating pre-existing INPUT directory"
   rm -rf $RUNDIR/INPUT
   mkdir $RUNDIR/INPUT
fi

#Make RESTART directory within the run directory if it doesn't already exist
if [ ! -d $RUNDIR/RESTART ]; then
   echo "Making $RUNDIR/RESTART..."
   mkdir $RUNDIR/RESTART
else
   echo "Removing and recreating pre-existing RESTART directory"
   rm -rf $RUNDIR/RESTART
   mkdir $RUNDIR/RESTART
fi

#Copy, rename, and link pre-processing NetCDF files to ${RUNDIR}/INPUT
cp ${out_dir}/${CRES}_grid.tile7.halo3.nc ${RUNDIR}/INPUT
ln -sf ${RUNDIR}/INPUT/${CRES}_grid.tile7.halo3.nc ${RUNDIR}/INPUT/${CRES}_grid.tile7.nc
cp ${out_dir}/${CRES}_grid.tile7.halo4.nc ${RUNDIR}/INPUT
ln -sf ${RUNDIR}/INPUT/${CRES}_grid.tile7.halo4.nc ${RUNDIR}/INPUT/grid.tile7.halo4.nc
cp ${out_dir}/${CRES}_mosaic.nc ${RUNDIR}/INPUT
ln -sf ${RUNDIR}/INPUT/${CRES}_mosaic.nc ${RUNDIR}/INPUT/grid_spec.nc
cp ${out_dir}/${CRES}_oro_data.tile7.halo0.nc ${RUNDIR}/INPUT/${CRES}_oro_data.tile7.halo0.nc
cp ${out_dir}/${CRES}_oro_data.tile7.halo4.nc ${RUNDIR}/INPUT/${CRES}_oro_data.tile7.halo4.nc
ln -sf ${RUNDIR}/INPUT/${CRES}_oro_data.tile7.halo0.nc ${RUNDIR}/INPUT/${CRES}_oro_data.tile7.nc
ln -sf ${RUNDIR}/INPUT/${CRES}_oro_data.tile7.halo0.nc ${RUNDIR}/INPUT/oro_data.nc
ln -sf ${RUNDIR}/INPUT/${CRES}_oro_data.tile7.halo4.nc ${RUNDIR}/INPUT/oro_data.tile7.halo4.nc
cp ${out_dir}/gfs* ${RUNDIR}/INPUT
ln -sf ${RUNDIR}/INPUT/gfs_data.tile7.nc ${RUNDIR}/INPUT/gfs_data.nc
cp ${out_dir}/sfc_data.tile7.nc ${RUNDIR}/INPUT
ln -sf ${RUNDIR}/INPUT/sfc_data.tile7.nc ${RUNDIR}/INPUT/sfc_data.nc

#############################################################################################################3###
# Math required for grid decomposition and sed commands to replace template values in namelists/configure files #
#################################################################################################################

#Verify that input.nml exists

if [ ! -f $RUNDIR/input.nml ]; then
   echo "input.xml does not exist.  Check your run directory.  Exiting..."
   exit 1
fi

#Verify that model_configure exists

if [ ! -f $RUNDIR/model_configure ]; then
   echo "model_configure does not exist.  Check your run directory.  Exiting..."
   exit 1
fi

#Verify that run script exists

if [ ! -f $RUNDIR/run.regional ]; then
   echo "Run script, run.regional, does not exist.  Check your run directory.  Exiting..."
   exit 1
fi

cd $RUNDIR

#Read lat and lon dimensions from NetCDF file
lat=$(ncdump -h ${RUNDIR}/INPUT/sfc_data.tile7.nc | grep "lat =" | sed -e "s/.*= //;s/ .*//")
lon=$(ncdump -h ${RUNDIR}/INPUT/sfc_data.tile7.nc | grep "lon =" | sed -e "s/.*= //;s/ .*//")

echo "FV3 domain dimensions for selected case:"
echo "Latitude = $lat"
echo "Longitude = $lon"
             
#Define npx and npy
npx=$(($lon+1))
npy=$(($lat+1))
    
echo ""
echo "For input.nml:"
echo "npx = $npx"
echo "npy = $npy"
echo ""
    
#Modify npx and npy values in input.nml
echo "Modifying npx and npy values in input.nml..."
echo ""
sed -i -r -e "s/^(\s*npx\s*=)(.*)/\1 $npx/" ${RUNDIR}/input.nml
sed -i -r -e "s/^(\s*npy\s*=)(.*)/\1 $npy/" ${RUNDIR}/input.nml

#Modify target_lat, target_lon, stretch_fac in input.nml
echo "Modifying target_lat and target_lon in input.nml..."
echo ""
sed -i -r -e "s/^(\s*target_lat\s*=)(.*)/\1 $target_lat/" ${RUNDIR}/input.nml
sed -i -r -e "s/^(\s*target_lon\s*=)(.*)/\1 $target_lon/" ${RUNDIR}/input.nml
sed -i -r -e "s/^(\s*stretch_fac\s*=)(.*)/\1 $stretch_fac/" ${RUNDIR}/input.nml
sed -i -r -e "s/^(\s*bc_update_interval\s*=)(.*)/\1 $BC_interval_hrs/" ${RUNDIR}/input.nml

#Test whether dimensions values are evenly divisible by user-chosen layout_x and layout_y.

#Make sure latitude dimension is divisible by layout_y.
if [[ $(( $lat%$layout_y )) -eq 0 ]]; then
   echo "Latitude dimension ($lat) is evenly divisible by user-defined layout_y ($layout_y)"
else
   echo "Latitude dimension ($lat) is not evenly divisible by user-defined layout_y ($layout_y), please redefine.  Exiting."
   exit 1
fi

#Make sure longitude dimension is divisible by layout_x.
if [[ $(( $lon%$layout_x )) -eq 0 ]]; then 
   echo "Longitude dimension ($lon) is evenly divisible by user-defined layout_x ($layout_x)"
else  
   echo "Longitude dimension ($lon) is not evenly divisible by user-defined layout_x ($layout_x), please redefine.  Exiting."
   exit 1
fi

#If the write component is turned on, make sure PE_MEMBER01 is divisible by write_tasks_per_group.
if [[ $quilting = ".true." ]]; then
 
 if [[ $(( (($layout_x*$layout_y)+($write_groups*$write_tasks_per_group))%$write_tasks_per_group )) -eq 0 ]]; then
    echo "Value of PE_MEMBER01 ($(( ($layout_x*$layout_y)+($write_groups*$write_tasks_per_group) ))) is evenly divisible by write_tasks_per_group ($write_tasks_per_group)."
 else
    echo "Value of PE_MEMBER01 ($(( ($layout_x*$layout_y)+($write_groups*$write_tasks_per_group) ))) is not evenly divisible by write_tasks_per_group ($write_tasks_per_group), please redefine.  Exiting."
    exit 1
 fi

else
  : #Do nothing
fi
 
echo ""
echo "Value for layout(x): $layout_x"
echo "Value for layout(y): $layout_y"
    
echo ""
echo "Layout for input.nml: $layout_x,$layout_y"
echo ""

#Modify layout_x and layout_y values in input.nml
echo "Modifying layout_x and layout_y values in input.nml..."
sed -i -r -e "s/^(\s*layout\s*=\s*)(.*)/\1$layout_x,$layout_y/" ${RUNDIR}/input.nml

#Calculate PE_MEMBER01
if [[ $quilting = ".true." ]]; then

#Add write_groups*write_tasks_per_group to the product of layout_x and layout_y for the write component.
PE_MEMBER01=$(( ($layout_x*$layout_y)+($write_groups*$write_tasks_per_group) ))

else

PE_MEMBER01=$(( $layout_x*$layout_y ))

fi

echo ""
echo "PE_MEMBER01 for model_configure: ${PE_MEMBER01}"
echo ""

#Modify values in model_configure
echo "Modifying quilting in model_configure... "
echo ""
sed -i -r -e "s/^(\s*quilting:\s*)(.*)/\1$quilting/" ${RUNDIR}/model_configure

echo "Modifying write_groups in model_configure... "
echo ""
sed -i -r -e "s/^(\s*write_groups:\s*)(.*)/\1$write_groups/" ${RUNDIR}/model_configure

echo "Modifying write_tasks_per_group in model_configure... "
echo ""
sed -i -r -e "s/^(\s*write_tasks_per_group:\s*)(.*)/\1$write_tasks_per_group/" ${RUNDIR}/model_configure

echo "Modifying PE_MEMBER01 in model_configure... "
echo ""
sed -i -r -e "s/^(\s*PE_MEMBER01:\s*)(.*)/\1$PE_MEMBER01/" ${RUNDIR}/model_configure

echo "Modifying simulation date and time in model_configure... "
echo ""
sed -i -r -e "s/^(\s*start_year:\s*)(<start_year>)(.*)/\1${YYYY}\3/" ${RUNDIR}/model_configure
sed -i -r -e "s/^(\s*start_month:\s*)(<start_month>)(.*)/\1${MM}\3/" ${RUNDIR}/model_configure
sed -i -r -e "s/^(\s*start_day:\s*)(<start_day>)(.*)/\1${DD}\3/" ${RUNDIR}/model_configure
sed -i -r -e "s/^(\s*start_hour:\s*)(<start_hour>)(.*)/\1${HH}\3/" ${RUNDIR}/model_configure

echo "Modifying forecast length in model_configure... "
echo ""
sed -i -r -e "s/^(\s*nhours_fcst:\s*)(.*)/\1$fcst_len_hrs/" ${RUNDIR}/model_configure

#Modify simulation date, time, and resolution in diag_table
echo "Modifying simulation date and time in diag_table... "
echo ""
sed -i -r -e "s/^<YYYYMMDD>\.<HH>Z\.<CRES>/${YMD}\.${HH}Z\.${CRES}/" ${RUNDIR}/diag_table
sed -i -r -e "s/^<YYYY>\s+<MM>\s+<DD>\s+<HH>\s+/${YYYY} ${MM} ${DD} ${HH} /" ${RUNDIR}/diag_table

#Modify cores per node
echo "Modifying number of cores per node in model_configure... "
echo ""
sed -i -r -e "s/^(\s*ncores_per_node:\s*)(.*)/\1$ncores_per_node/" ${RUNDIR}/model_configure

#Calculate values for nodes and ppn for job scheduler
PPN=$ncores_per_node 
      
Nodes=$(( ($PE_MEMBER01+$ncores_per_node-1)/$ncores_per_node ))

echo "Nodes: $Nodes"
echo "PPN: $PPN"
echo"" 
    
#Modify nodes and PPN in the run script
echo "Modifying nodes and PPN in run.regional..."
echo ""
sed -i -r -e "s/^(#PBS.*nodes=)([^:]*)(:.*)/\1$Nodes\3/" ${RUNDIR}/run.regional
sed -i -r -e "s/(ppn=)(.*)/\1$PPN/" ${RUNDIR}/run.regional

#Modify $RUNDIR in run.regional
echo "Modifying run directory in run.${CRES}.regional..."
sed -i -r -e 's+\$\{RUNDIR\}+'"${RUNDIR}"'+' ${RUNDIR}/run.regional

#Modify $PBS_NP in run.regional
echo "Modifying \$PBS_NP directory in run.${CRES}.regional..."
sed -i -r -e 's+\$PBS_NP+'"${PE_MEMBER01}"'+' ${RUNDIR}/run.regional

#Modify FV3 run proc in FV3_Theia.xml
echo "Modifying FV3 run proc in FV3_Theia.xml..."
REGEXP="(^\s*<!ENTITY\s*FV3_PROC\s*\")(.*)(\">.*)"
sed -i -r -e "s/$REGEXP/\1${Nodes}:ppn=${PPN}\3/g" ${BASEDIR}/fv3gfs/regional/FV3_Theia.xml
