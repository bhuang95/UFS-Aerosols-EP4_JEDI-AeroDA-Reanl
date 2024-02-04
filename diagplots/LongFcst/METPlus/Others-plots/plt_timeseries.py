import sys,os,argparse
from scipy.stats import gaussian_kde
import numpy as np
from netCDF4 import Dataset as NetCDFFile
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
sys.path.append('/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/Libs/Python')
import mpl_scatter_density
from matplotlib.colors import LinearSegmentedColormap
from astropy.visualization import LogStretch
from astropy.visualization.mpl_normalize import ImageNormalize
from fast_histogram import histogram2d

def open_ncfile(ncfile):
    print('Open file: ', ncfile)
    try:
        ncind=NetCDFFile(ncfile)
    except OSError:
        print('Cannot open file: ', ncfile)
        quit()
    return ncind

def readsample(datafile):
    
    try: 
        f=open(datafile,'r')
    except OSError:
        print('Cannot open file: ', datafile)
        quit()
    datavec=[]
    for line in f.readlines():
        data=float(line.split()[0])
        datavec.append(data)
    f.close()
    return datavec

def plot_line(data, plegs, pcols, plines, pmarks, xarr, xlab, ylab, ypert, pstr):
    tfsize=14
    lfsize=14
    fig = plt.figure(figsize=[8,4])
    ax=fig.add_subplot(111)
    #ax.set_title(f'{plttit}', fontsize = tfsize)
    irun=0
    if ypert==1:
        #data = data*100
        #data = [x * 100 for x in data]
        data = [[j*100 for j in i] for i in data]
        data = data * 100
        #for x in data:
        #    for y in x:
        #        y = y*100
    print('HBO2')
    print(data.shape)
    nx, ny = data.shape
    for ix in range(nx):
        plt.plot(xarr, data[ix,:], linewidth=2, marker=pmarks[irun], linestyle=plines[irun], color=pcols[irun],label=plegs[irun])
        irun+=1
    #ax.set_xticks(ax.get_xticks()[::2])
    ax.grid(color='lightgrey', linestyle='--', linewidth=1)
    if ypert==1:
        ax.yaxis.set_major_formatter(mtick.PercentFormatter())
    plt.xlabel(xlab, fontsize=lfsize)
    plt.ylabel(ylab, fontsize=lfsize)
    plt.xticks(fontsize=lfsize)
    plt.yticks(fontsize=lfsize)
    plt.legend(loc="best", fontsize=lfsize, frameon=False)
    fig.tight_layout()
    plt.savefig(f"{pstr}.png")
    return

if __name__ == '__main__':
    '''
    parser = argparse.ArgumentParser(
        description=(
            'Print AOD and its hofx in obs space and their difference'
        )
    )

    required = parser.add_argument_group(title='required arguments')
    required.add_argument(
        '-e', '--expname',
        help="Expname",
        type=str, required=True)

    required.add_argument(
        '-o', '--calstat',
        help="Calculate stats",
        type=str, required=True)

    required.add_argument(
        '-p', '--fpre',
        help="File prefix",
        type=str, required=True)

    args = parser.parse_args()
    expname = args.expname
    calcstat = args.expname == "YES"
    fpre = args.fpre
    '''

    rundir='/scratch2/BMC/gsd-fv3-dev/bhuang/expRuns/UFS-Aerosols_RETcyc/'
    diagdir='diagplots/LongFcst/AODReana/'
    cycs='2020060800-2020063000'
    lfcsttype='longfcst'

    expruns=[
        'RET_EP4_FreeRun_NoSPE_YesSfcanl_v15_0dz0dp_1M_C96_202006',
	'RET_EP4_AeroDA_NoSPE_YesSfcanl_v15_0dz0dp_41M_C96_202006',
        'RET_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202006'
        ]
#	'RET_EP4_AeroDA_NoSPE_YesSfcanl_v15_0dz0dp_41M_C96_202006',
#	'RET_EP4_AeroDA_YesSPEEnKF_YesSfcanl_v15_0dz0dp_41M_C96_202006'
    obstypes=['camseac4', 'merra2']
    plegs=['FreeRun', 'AeroDA', 'AeroDA-SPE']
    pcols=['blake','red', 'blue']
    plines=['-', '-', '-',]
    pmarks=['o', 'o', 'o']

    fhmin=0
    fhmax=120+1
    fhout=6

    fvars = [
       'series_cnt_FBAR',
       'series_cnt_OBAR',
       'series_cnt_ME',
       'series_cnt_MSE',
       'series_cnt_MAE',
       'series_cnt_PR_CORR'
        ]

    calcstat = True
    for obstype in obstypes:
        fpre=f'fv3_{obstype}_AODSTAT_2D'

        if calcstat:
            readlat = True

            for exprun in expruns:

                for fhr in range(fhmin, fhmax, fhout):
                    fhrpad = str(fhr).zfill(3)
                    fhrstr = f'fhr{fhrpad}'
                    fhrfile = f'{rundir}/{exprun}/{diagdir}/PLOTS-{lfcsttype}-{cycs}/{obstype}/{fpre}_{fhrstr}.nc'

                    ncind=open_ncfile(fhrfile)
                    outfile = f'data/{exprun}_{obstype}_FBAR_OBAR_ME_RMSE_MAE_R2_{fhrstr}.txt'
                    outdata = []

                    if readlat:
                        lat=ncind.variables['lat'][:]
                        lon=ncind.variables['lon'][:]
                        lons,lats = np.meshgrid(lon,lat)
                        llweights = np.cos(np.deg2rad(lats))
                        readlat = False

                    for fvar in fvars:
                        data=ncind.variables[fvar][:]
                        mdata = np.average(data, weights = llweights)
                        if fvar == 'series_cnt_MSE':
                             mdata = np.sqrt(mdata)
                        if fvar == 'series_cnt_PR_CORR':
                             mdata = mdata*mdata
                        outdata.append(mdata)
                    np.savetxt(outfile, outdata, fmt='%12.6f') 
                ncind.close()
        
        lst3d=[]
        for exprun in expruns:
            lst2d=[]
            for fhr in range(fhmin, fhmax, fhout):
                fhrpad = str(fhr).zfill(3)
                fhrstr = f'fhr{fhrpad}'
                fhrfile = f'{fpre}_{fhrstr}.nc'
                
                infile = f'data/{exprun}_{obstype}_FBAR_OBAR_ME_RMSE_MAE_R2_{fhrstr}.txt'
                print(infile)
                lst1d = readsample(infile)
                lst2d.append(lst1d)
            lst3d.append(lst2d)
        arr3d = np.array(lst3d)
        print('HBO1')
        print(arr3d.shape)

        nx, ny, nz = arr3d.shape

        xarr=[*range(fhmin, fhmax, fhout)]
        xarrstr=str(xarr)
        print('HBO3')
        print(len(xarrstr))
        print(xarrstr)
        xlab="Forecast (days)"
        ypert= 0
        for iz in range(nz):
            data = arr3d[:,:,iz]
            if iz == 0: pstr = f'{obstype}_FBAR'; ylab='Model Mean'
            if iz == 1: pstr = f'{obstype}_OBAR'; ylab='Reanalysis Mean'
            if iz == 2: pstr = f'{obstype}_ME';   ylab='Mean Bias'
            if iz == 3: pstr = f'{obstype}_RMSE'; ylab='Mean RMSE'
            if iz == 4: pstr = f'{obstype}_MAE';  ylab='Mean Abs. Error'
            if iz == 5: pstr = f'{obstype}_R2'; ylab='R\u00b2'
            ypert=0
            pp=plot_line(data, plegs, pcols, plines, pmarks, xarr, xlab, ylab, ypert, pstr)
