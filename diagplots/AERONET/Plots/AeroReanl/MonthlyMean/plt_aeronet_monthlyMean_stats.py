import sys,os,argparse
sys.path.append('/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/METplus-diag/METplus_pkg//pyscripts/lib')
os.environ['PROJ_LIB'] = '/contrib/anaconda/anaconda3/latest/share/proj'
#from mpl_toolkits.basemap import Basemap
#from netCDF4 import Dataset as NetCDFFile
import numpy as np
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
#import matplotlib.cm as cm
from matplotlib import gridspec
from matplotlib.dates import (DAILY, DateFormatter,
                              rrulewrapper, RRuleLocator)
from ndate import ndate
from datetime import datetime
from datetime import timedelta
import matplotlib.dates as mdates


def coll_monthlymean_samples(infile):
    ls1 = []
    ls2 = []
    ls3 = []
    ls4 = []
    with open(infile, 'r') as fin:
        for line in fin.readlines():
            tmp1 = str(line.split()[0])
            tmp2 = float(line.split()[1])
            tmp3 = float(line.split()[2])
            tmp4 = float(line.split()[3])
            ls1.append(tmp1)
            ls2.append(tmp2)
            ls3.append(tmp3)
            ls4.append(tmp4)
    return ls1, ls2, ls3, ls4

def plot_monthlymean(xdata, ydata1, ydata2, xlab, ylab, yran, ptitle, pname):
    fsize = 14
    fig = plt.figure(figsize=[8,4])
    ax=fig.add_subplot(111)
    #ax.set_title(f'{plttit}', fontsize = fsize)
    #for iv in range(nvars):
    nlen=len(xdata)
    mtmp1=sum(ydata1)/nlen
    mtmp2=sum(ydata2)/nlen
    m1=[mtmp1]*nlen
    m2=[mtmp2]*nlen
    plt.plot(xdata, ydata1, '-bo', label='FreeRun', linewidth=2.5)
    plt.plot(xdata, ydata2, '-ro', label='Reanalysis', linewidth=2.5)
    plt.plot(xdata, m1, '--b',linewidth=2)
    plt.plot(xdata, m2, '--r', linewidth=2)
    plt.legend(loc='best', fontsize=fsize)
    plt.xlabel(xlab, fontsize=fsize)
    plt.xticks(rotation=315, ha='center')
    plt.ylabel(ylab, fontsize=fsize)
    plt.xticks(fontsize=fsize)
    plt.yticks(fontsize=fsize)
    plt.grid(linestyle=':')
    plt.title(ptitle)
    plt.ylim(yran[0], yran[1])
    fig.tight_layout()
    plt.savefig(pname, format='png')

if __name__ == '__main__':
   r2='201801run_R2'
   inputfile=f'{r2}.out'
   mons, freerun, dafcst, daanl = coll_monthlymean_samples(inputfile)
   xdata=mons
   ydata1=freerun
   ydata2=daanl
   ylab='AOD R\u00b2'
   xlab='Month/Year'
   ptitle='Monthly mean R\u00b2 w/ AERONET 500nm AOD'
   pname=f'{r2}.png'
   yran=[0.0, 0.8]
   plt1=plot_monthlymean(xdata, ydata1, ydata2, xlab, ylab, yran, ptitle, pname)

   bias='201801run_bias'
   inputfile=f'{bias}.out'
   mons, freerun, dafcst, daanl = coll_monthlymean_samples(inputfile)
   xdata=mons
   ydata1=freerun
   ydata2=daanl
   ylab='AOD Bias'
   xlab='Month/Year'
   ptitle='Monthly mean Bias w/ AERONET 500nm AOD'
   pname=f'{bias}.png'
   yran=[-0.14, 0]
   plt1=plot_monthlymean(xdata, ydata1, ydata2, xlab, ylab, yran, ptitle, pname)

   r2='202007run_R2'
   inputfile=f'{r2}.out'
   mons, freerun, dafcst, daanl = coll_monthlymean_samples(inputfile)
   xdata=mons
   ydata1=freerun
   ydata2=daanl
   ylab='AOD R\u00b2'
   xlab='Month/Year'
   ptitle='Monthly mean R\u00b2 w/ AERONET 500nm AOD'
   pname=f'{r2}.png'
   yran=[0.0, 0.8]
   plt1=plot_monthlymean(xdata, ydata1, ydata2, xlab, ylab, yran, ptitle, pname)

   bias='202007run_bias'
   inputfile=f'{bias}.out'
   mons, freerun, dafcst, daanl = coll_monthlymean_samples(inputfile)
   xdata=mons
   ydata1=freerun
   ydata2=daanl
   ylab='AOD Bias'
   xlab='Month/Year'
   ptitle='Monthly mean Bias w/ AERONET 500nm AOD'
   pname=f'{bias}.png'
   yran=[-0.14, 0]
   plt1=plot_monthlymean(xdata, ydata1, ydata2, xlab, ylab, yran, ptitle, pname)
exit()
