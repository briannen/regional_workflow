#!/bin/bash --login

#SBATCH --account=comgsi
#SBATCH --partition=service
#SBATCH --job-name=add_perts
#SBATCH --ntasks=1
#SBATCH --time=6:00:00
#SBATCH --mem=48g
#SBATCH --output=./add_perts.o.log
#SBATCH --error=./add_perts.e.log

# This script adds perturbations derived from GEFS initialization data, after it was processed
# through the make_ics (chgres_cubed) task of the SRW App workflow.

#mem01 on the hrrr initialized members will remain unperturbed as the control.
#mem02..10 will be perturbed from the GEFS members 01..09, respectively

set -x

module load intel/2022.1.2
module load nco

#perts_dir=/scratch2/BMC/fv3lam/ens_design_RRFS/expt_dirs_IC_perts/ens_perts
perts_dir=/scratch2/BMC/fv3lam/mayfield/ens_IC_pert_test/expt_dirs_GEFS_perts/ens_perts

#for cyc in 202205{27..31} 202206{01..09} ; do
#for cyc in 20220430 202205{01..12} ; do
for cyc in 20220430 ; do

    #RRFS_dir=/scratch2/BMC/fv3lam/ens_design_RRFS/expt_dirs/IC_perts/${cyc}00
    RRFS_dir=/scratch2/BMC/fv3lam/mayfield/ens_IC_pert_test/expt_dirs/IC_perts/${cyc}00

    for mem in {1..9} ; do

        # Add GEFS perturbations 01 through 09 to RRFS members 02 through 10, respectively.
        mem_GEFS=$(printf "%02d" $mem)
        mem_RRFS=$(printf "%02d" $((mem + 1)))

        #store old files
        mv ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_data.tile7.halo0.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_data.tile7.halo0.nc_orig
        mv ${RRFS_dir}/mem${mem_RRFS}/INPUT/sfc_data.tile7.halo0.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/sfc_data.tile7.halo0.nc_orig
        mv ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_bndy.tile7.000.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_bndy.tile7.000.nc_orig

        python add_ic_pert.py ${perts_dir}/${cyc}00_GEFS_pert_mem${mem_GEFS}_gfs_data.tile7.halo0.nc ${RRFS_dir}/mem01/INPUT/gfs_data.tile7.halo0.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_data.tile7.halo0.nc 
        python add_ic_pert.py ${perts_dir}/${cyc}00_GEFS_pert_mem${mem_GEFS}_sfc_data.tile7.halo0.nc_soil_9_layers ${RRFS_dir}/mem01/INPUT/sfc_data.tile7.halo0.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/sfc_data.tile7.halo0.nc
        python add_ic_pert.py ${perts_dir}/${cyc}00_GEFS_pert_mem${mem_GEFS}_gfs_bndy.tile7.000.nc ${RRFS_dir}/mem01/INPUT/gfs_bndy.tile7.000.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_bndy.tile7.000.nc

        
        # use the RRFS mem01 ICs as the base and add the pert from GEFS members, place result into RRFS mem02..10 directories
        #ncbo -O --op_typ=add ${perts_dir}/${cyc}18_GEFS_pert_mem${mem_GEFS}_gfs_data.tile7.halo0.nc ${RRFS_dir}/mem01/INPUT/gfs_data.tile7.halo0.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_data.tile7.halo0.nc
        # use the modified surface file with 9 soil layers to match RRFS ICs (HRRR)
        #ncbo -O --op_typ=add ${perts_dir}/${cyc}18_GEFS_pert_mem${mem_GEFS}_sfc_data.tile7.halo0.nc_soil_9_layers ${RRFS_dir}/mem01/INPUT/sfc_data.tile7.halo0.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/sfc_data.tile7.halo0.nc
        #ncbo -O --op_typ=add ${perts_dir}/${cyc}18_GEFS_pert_mem${mem_GEFS}_gfs_bndy.tile7.000.nc ${RRFS_dir}/mem01/INPUT/gfs_bndy.tile7.000.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_bndy.tile7.000.nc

        #restore non-perturbed files
        #cp ${RRFS_dir}/mem01/INPUT/gfs_data.tile7.halo0.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_data.tile7.halo0.nc
        #cp ${RRFS_dir}/mem01/INPUT/gfs_bndy.tile7.000.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/gfs_bndy.tile7.000.nc
        #cp ${RRFS_dir}/mem01/INPUT/sfc_data.tile7.halo0.nc ${RRFS_dir}/mem${mem_RRFS}/INPUT/sfc_data.tile7.halo0.nc
    done
done

