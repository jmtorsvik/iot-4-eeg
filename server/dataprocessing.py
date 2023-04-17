import numpy as np
import pandas as pd
import mne
import scipy 
from numpy.fft import fft
import matplotlib.pyplot as plt
from matplotlib import rc
rc('text', usetex=True)

### DATA PREPROCESSING

# Data collection
df = pd.read_csv("server/e_bolger")

t = df["time"]
sample_rate = 230 #Hz
EEG = (3.3/4096)*df["sensorValue"] # Deler 3.3v på 4096 og ganger med data for å få spenning
EEG_mean = np.mean(EEG)
EEG = EEG - EEG_mean # Zero center data

# Transforming data in a way that MNE can interpret and do filtering
EEG = EEG.to_frame()
data = EEG.to_numpy().T

EEG.to_csv("EEGdata.csv")

ch_names = EEG.columns.tolist()
ch_types = ['eeg'] * len(ch_names)
sfreq = sample_rate  # replace with your sampling frequency
info = mne.create_info(ch_names=ch_names, ch_types=ch_types, sfreq=sfreq)

# Create Raw object to be filtered
raw = mne.io.RawArray(data, info)

# Filter settings for band pass
low_cut = 0.1
high_cut = 40

# Filtering
raw_filt = raw.copy().filter(low_cut, high_cut)
print(type(raw_filt))

# Unpack data and set up variables
x = raw_filt._data[0]                               # Relabel the data variable
dt = 1/sample_rate                      # Define the sampling interval
N = len(x)                        # Define the total number of data points
T = N * dt                            # Define the total duration of the data
time_axis = np.arange(0,T,dt)

### DATA ANALYSIS

# Compute Fourier transform and PSD
xf = fft(x - x.mean())                # Compute Fourier transform of x
Sxx = 2 * dt ** 2 / T * (xf * xf.conj())  # Compute spectrum
Sxx = Sxx[:int(len(x) / 2)]           # Ignore negative frequencies

# Setup variables for plotting
df = 1 / T                      # Determine frequency resolution
fNQ = 1 / dt / 2                      # Determine Nyquist frequency
faxis = np.arange(0,fNQ-df,df)              # Construct frequency axis

# Frequency band limits
delta_lim = [0.5, 4]
theta_lim = [4, 8]
alpha_lim = [8, 12]
beta_lim = [12, 30]

# Compute power for each frquency band
def bandpower(x, fs, fmin, fmax):
    f, Pxx = scipy.signal.periodogram(x, fs=fs)
    ind_min = scipy.argmax(f > fmin) - 1
    ind_max = scipy.argmax(f > fmax) - 1
    return scipy.trapz(Pxx[ind_min: ind_max], f[ind_min: ind_max])

powers = [bandpower(data[0], sample_rate, delta_lim[0], delta_lim[1]),
          bandpower(data[0], sample_rate, theta_lim[0], theta_lim[1]),
          bandpower(data[0], sample_rate, alpha_lim[0], alpha_lim[1]),
          bandpower(data[0], sample_rate, beta_lim[0], beta_lim[1])]

print(powers)

# Compute relative power for each frequency band
sum_powers = np.sum(powers)
relative_powers = [powers[0]/sum_powers, powers[1]/sum_powers, powers[2]/sum_powers, powers[3]/sum_powers]


### PLOTTING

# Plot filtered time series data
plt.plot(time_axis, EEG)
plt.xlabel('Time [Sec]')
plt.ylabel('$\mu V$')
plt.title("Filtered EEG timeseries data")

plt.savefig("timeseries.pdf")

# Plot Power and Spectrum
fig, axis = plt.subplots(2)
       
xlabel = ["delta","theta","alpha","beta"]
axis[0].bar(xlabel, powers)
axis[0].set_title("Power for frequency bands")
axis[0].set_ylabel('Power [$\mu V^2$/Hz]')
axis[0].set_xlabel(r"\textbf{Frequency band: Power (Relative power)}" + 
                   "\nDelta: " + str(np.round_(powers,6)[0]) + " (" + str(np.round_(relative_powers,6)[0]) + ")" +
                   "\nTheta: " + str(np.round_(powers,6)[1]) + " (" + str(np.round_(relative_powers,6)[1]) + ")" +
                   "\nAlpha: " + str(np.round_(powers,6)[2]) + " (" + str(np.round_(relative_powers,6)[2]) + ")" +
                   "\nBeta: "  + str(np.round_(powers,6)[3]) + " (" + str(np.round_(relative_powers,6)[3]) + ")" 
                   , position=(0., 1e6), horizontalalignment='left')

axis[1].plot(faxis, Sxx.real)
axis[1].set_xscale('log')
axis[1].grid(True, which="both")
axis[1].set_xlabel('Frequency [Hz]')
axis[1].set_ylabel('Power [$\mu V^2$/Hz]')
axis[1].set_title("Spectrum of EEG signal")

fig.tight_layout()

plt.savefig("results.pdf")