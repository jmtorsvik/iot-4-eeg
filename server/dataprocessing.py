import numpy as np
import pandas as pd
import mne
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

# Plot filtered time series data
fig = plt.plot(time_axis, EEG)
plt.xlabel('Time [Sec]')
plt.ylabel('$\mu V$')
plt.title("Filtered EEG data")
plt.show()

### DATA ANALYSIS

# Compute Fourier transform and PSD
xf = fft(x - x.mean())                # Compute Fourier transform of x
Sxx = 2 * dt ** 2 / T * (xf * xf.conj())  # Compute spectrum
Sxx = Sxx[:int(len(x) / 2)]           # Ignore negative frequencies

# Compute and plot PSD with mne function
raw_filt.plot_psd(fmax=100)

# Setup variables for plotting
df = 1 / T                      # Determine frequency resolution
fNQ = 1 / dt / 2                      # Determine Nyquist frequency
faxis = np.arange(0,fNQ-df,df)              # Construct frequency axis

# Frequency band limits
delta_lim = [0.1, 4]
theta_lim = [4, 8]
alpha_lim = [8, 12]
beta_lim = [12, 30]

# Compute power for each frquency band
powers = [0,0,0,0]

for i in range(len(faxis)):
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


### PLOTTING

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

axis[1].plot(faxis, Sxx.real)
axis[1].set_xscale('log')
axis[1].grid(True, which="both")
axis[1].set_xlabel('Frequency [Hz]')
axis[1].set_ylabel('Power [$\mu V^2$/Hz]')
axis[1].set_title("Spectrum of EEG signal")

fig.tight_layout()

plt.savefig("results.pdf")