import numpy as np
import pandas as pd

df = pd.read_csv('server/Data1.csv')
df.head()

df = df.drop(['Unnamed: 0', 'trial number','sensor position', 'subject identifier', 'matching condition', 'channel'], axis=1)
df = df.rename(columns={'sample num':'sessionID', 'name':'UID'})

# Analysing EEG with FFT from scipy
from numpy.fft import fft
import matplotlib.pyplot as plt

# Data
t = df["time"]
sample_rate = len(t)
EEG = df["sensor value"]
n = len(EEG)

x = EEG                               # Relabel the data variable
dt = t[1] - t[0]                      # Define the sampling interval
N = x.shape[0]                        # Define the total number of data points
T = N * dt                            # Define the total duration of the data

xf = fft(x - x.mean())                # Compute Fourier transform of x
Sxx = 2 * dt ** 2 / T * (xf * xf.conj())  # Compute spectrum
Sxx = Sxx[:int(len(x) / 2)]           # Ignore negative frequencies

df = 1 / T.max()                      # Determine frequency resolution
fNQ = 1 / dt / 2                      # Determine Nyquist frequency
faxis = np.arange(0,fNQ,df)              # Construct frequency axis

delta_lim = [0.1, 4]
theta_lim = [4, 8]
alpha_lim = [8, 12]
beta_lim = [12, 30]

energies = [0,0,0,0]

for i in range(len(faxis)):
    freq = xf[i]
    if freq > delta_lim[0] and freq < delta_lim[1]:
        energies[0] += Sxx.real[i]
    if freq > theta_lim[0] and freq < delta_lim[1]:
        energies[1] += Sxx.real[i]
    if freq > alpha_lim[0] and freq < alpha_lim[1]:
        energies[2] += Sxx.real[i]
    if freq > beta_lim[0] and freq < beta_lim[1]:
        energies[3] += Sxx.real[i]

print(energies)  

fig, axis = plt.subplots(2)
       
xlabel = ["delta","theta","alpha","beta"]
axis[0].bar(xlabel, energies)
axis[0].set_title("Energy for brain waves")

axis[1].plot(faxis, Sxx.real)
axis[1].set_xlim([0, 100])
axis[1].set_xlabel('Frequency [Hz]')
axis[1].set_ylabel('Power [$\mu V^2$/Hz]')

plt.savefig("results.pdf")