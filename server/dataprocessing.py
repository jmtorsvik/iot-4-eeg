import numpy as np
import pandas as pd

df = pd.read_csv('Data1.csv')
df.head()

df = df.drop(['Unnamed: 0', 'trial number','sensor position', 'subject identifier', 'matching condition', 'channel'], axis=1)
df = df.rename(columns={'sample num':'sessionID', 'name':'UID'})

# Analysing EEG with FFT from scipy
from numpy.fft import fft
import matplotlib.pyplot as plt
from matplotlib import rc
rc('text', usetex=True)

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

# Filter out unwanted frequencies
def high_pass(freq):
    if freq >= delta_lim[0]:
        return True
    return False

final_faxis = list(filter(high_pass, faxis))
start = len(faxis) - len(final_faxis)
xf = xf[start:]
Sxx_real = Sxx.real[start:]


powers = [0,0,0,0]

# Sum PSD for every frequency band
for i in range(len(final_faxis)):
    freq = xf[i]
    if freq > delta_lim[0] and freq < delta_lim[1]:
        powers[0] += Sxx.real[i]
    if freq > theta_lim[0] and freq < delta_lim[1]:
        powers[1] += Sxx.real[i]
    if freq > alpha_lim[0] and freq < alpha_lim[1]:
        powers[2] += Sxx.real[i]
    if freq > beta_lim[0] and freq < beta_lim[1]:
        powers[3] += Sxx.real[i]

print(powers)

# Compute relative power for each frequency band
sum_powers = np.sum(powers)
relative_powers = [powers[0]/sum_powers, powers[1]/sum_powers, powers[2]/sum_powers, powers[3]/sum_powers]



fig, axis = plt.subplots(2)
       
xlabel = ["delta","theta","alpha","beta"]
axis[0].bar(xlabel, powers)
axis[0].set_title("Power for frequency bands")
axis[0].set_ylabel('Power [$\mu V^2$/Hz]')
axis[0].set_xlabel(r"\textbf{Frequency band: Power (Relative power)}" + 
                   "\nDelta: " + str(np.round_(powers,3)[0]) + " (" + str(np.round_(relative_powers,3)[0]) + ")" +
                   "\nTheta: " + str(np.round_(powers,3)[1]) + " (" + str(np.round_(relative_powers,3)[1]) + ")" +
                   "\nAlpha: " + str(np.round_(powers,3)[2]) + " (" + str(np.round_(relative_powers,3)[2]) + ")" +
                   "\nBeta: "  + str(np.round_(powers,3)[3]) + " (" + str(np.round_(relative_powers,3)[3]) + ")" 
                   , position=(0., 1e6), horizontalalignment='left')

axis[1].semilogx(final_faxis, Sxx_real)
axis[1].grid(True, which="both")
axis[1].set_xlim([0, 100])
axis[1].set_xlabel('Frequency [Hz]')
axis[1].set_ylabel('Power [$\mu V^2$/Hz]')
axis[1].set_title("Spectrum of EEG signal")

fig.tight_layout()

plt.savefig("results.pdf")