#!/bin/bash

function file_location() {

  # Return the default location of external model files on disk

  local external_file_fmt external_model location

  external_model=${1}
  external_file_fmt=${2}

  location=""
  case ${external_model} in

    "FV3GFS")
#      location='/scratch1/NCEPDEV/rstprod/com/gfs/prod/gfs.${yyyymmdd}/${hh}/atmos'
# The "prod" subdirectory has been deleted.  Not sure where the new one
# is, so for now set it to "para".  This needs to be done because the
# run_WE2E_tests.sh script checks for the existence of this directory.
      location='/scratch1/NCEPDEV/rstprod/com/gfs/para/gfs.${yyyymmdd}/${hh}/atmos'
      ;;

  esac
  echo ${location:-}

}

EXTRN_MDL_SYSBASEDIR_ICS=${EXTRN_MDL_SYSBASEDIR_ICS:-$(file_location \
  ${EXTRN_MDL_NAME_ICS} \
  ${FV3GFS_FILE_FMT_ICS})}
EXTRN_MDL_SYSBASEDIR_LBCS=${EXTRN_MDL_SYSBASEDIR_LBCS:-$(file_location \
  ${EXTRN_MDL_NAME_LBCS} \
  ${FV3GFS_FILE_FMT_LBCS})}

EXTRN_MDL_DATA_STORES=${EXTRN_MDL_DATA_STORES:-"hpss aws nomads"}

# System scripts to source to initialize various commands within workflow
# scripts (e.g. "module").
if [ -z ${ENV_INIT_SCRIPTS_FPS:-""} ]; then
  ENV_INIT_SCRIPTS_FPS=( "/etc/profile" )
fi

# Commands to run at the start of each workflow task.
PRE_TASK_CMDS='{ ulimit -s unlimited; ulimit -a; }'

# Architecture information
WORKFLOW_MANAGER="rocoto"
NCORES_PER_NODE=${NCORES_PER_NODE:-40}
SCHED=${SCHED:-"slurm"}
PARTITION_DEFAULT=${PARTITION_DEFAULT:-"hera"}
QUEUE_DEFAULT=${QUEUE_DEFAULT:-"batch"}
PARTITION_HPSS=${PARTITION_HPSS:-"service"}
QUEUE_HPSS=${QUEUE_HPSS:-"batch"}
PARTITION_FCST=${PARTITION_FCST:-"hera"}
QUEUE_FCST=${QUEUE_FCST:-"batch"}

# UFS SRW App specific paths
staged_data_dir="/scratch2/BMC/det/UFS_SRW_App/develop"
#FIXgsm=${FIXgsm:-"${staged_data_dir}/fix/fix_am"}
FIXgsm=${FIXgsm:-"/scratch2/BMC/fv3lam/ens_design_RRFS/FIX_RRFS/am"}
#FIXaer=${FIXaer:-"${staged_data_dir}/fix/fix_aer"}
FIXaer=${FIXaer:-"/scratch2/BMC/fv3lam/ens_design_RRFS/FIX_RRFS/am"}
#FIXlut=${FIXlut:-"${staged_data_dir}/fix/fix_lut"}
FIXlut=${FIXlut:-"/scratch2/BMC/fv3lam/ens_design_RRFS/FIX_RRFS/am"}
TOPO_DIR=${TOPO_DIR:-"${staged_data_dir}/fix/fix_orog"}
SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"${staged_data_dir}/fix/fix_sfc_climo"}
DOMAIN_PREGEN_BASEDIR=${DOMAIN_PREGEN_BASEDIR:-"${staged_data_dir}/FV3LAM_pregen"}

# Run commands for executables
RUN_CMD_SERIAL="time"
RUN_CMD_UTILS="srun"
RUN_CMD_FCST="srun"
RUN_CMD_POST="srun"

# MET/METplus-Related Paths
MET_INSTALL_DIR=${MET_INSTALL_DIR:-"/contrib/met/10.1.1"}
METPLUS_PATH=${METPLUS_PATH:-"/contrib/METplus/METplus-4.1.1"}
CCPA_OBS_DIR=${CCPA_OBS_DIR:-"${staged_data_dir}/obs_data/ccpa/proc"}
MRMS_OBS_DIR=${MRMS_OBS_DIR:-"${staged_data_dir}/obs_data/mrms/proc"}
NDAS_OBS_DIR=${NDAS_OBS_DIR:-"${staged_data_dir}/obs_data/ndas/proc"}

# Test Data Locations
TEST_COMIN="${staged_data_dir}/COMGFS"
TEST_PREGEN_BASEDIR="${staged_data_dir}/FV3LAM_pregen"
TEST_EXTRN_MDL_SOURCE_BASEDIR="${staged_data_dir}/input_model_data"
TEST_ALT_EXTRN_MDL_SYSBASEDIR_ICS="/scratch2/BMC/det/UFS_SRW_app/dummy_FV3GFS_sys_dir"
TEST_ALT_EXTRN_MDL_SYSBASEDIR_LBCS="/scratch2/BMC/det/UFS_SRW_app/dummy_FV3GFS_sys_dir"
