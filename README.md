# **TCC Project: Optimization of Post-Quantum Signatures and Parallel Hashing in Blockchain**

---

## **Table of Contents**
1. [Project Description](#project-description)
2. [Concepts](#concepts)
   - Blockchain  
   - Hashing Algorithms  
   - Sequential vs Parallel Processing  
   - Benchmark Metrics  
3. [Setup Instructions (From Scratch)](#setup-instructions)
4. [Scripts Overview](#scripts-overview)
5. [Running the Benchmark](#running-the-benchmark)
6. [Generated Plots and Results](#generated-plots-and-results)
7. [Results Analysis](#results-analysis)
8. [Future Improvements](#future-improvements)

---

## **1. Project Description**  
This project benchmarks the performance of sequential and parallel hashing algorithms in a blockchain environment. The results are analyzed to determine the impact of parallel processing on performance metrics such as throughput, latency, and resource usage.  

Additionally, the work explores hybrid cryptography (post-quantum) integration into blockchain transactions.

---

## **2. Concepts**

### **Blockchain**  
A blockchain is a distributed, immutable ledger for recording transactions. Each block in the chain contains:
- Transaction data
- A cryptographic hash of the block  
- A timestamp  

Hashes ensure the integrity of the blockchain by creating a **fingerprint** of the block's content.

---

### **Hashing Algorithms**  
Hashing algorithms are used to secure data and create a unique, fixed-size representation (digest) of variable-size inputs. The following algorithms were benchmarked:  
- **SHA256**: A widely used cryptographic hash function.  
- **SHA512**: Produces longer digests, enhancing security.  
- **BLAKE3**: Optimized for speed and parallelism.  
- **BLAKE2b**: Faster than SHA256 while maintaining cryptographic security.  
- **MD5**: Outdated but included for comparison purposes.  

---

### **Sequential vs Parallel Processing**  
- **Sequential Processing**: Tasks are executed one after another.  
- **Parallel Processing**: Multiple tasks are executed simultaneously, leveraging multiple CPU cores.  

---

### **Benchmark Metrics**  
The project evaluates:
- **Throughput**: Assets processed per second  
- **Latency**: Time taken to hash an asset  
- **Resource Usage**: CPU and memory consumption  
- **Improvement Metrics**: Relative speed-up in parallel processing  

---

## **3. Setup Instructions**

### **Pre-Requisites**
Ensure the following are installed:
1. **Docker**  
   [Install Docker](https://docs.docker.com/get-docker/)  
2. **Docker Compose**  
   [Install Docker Compose](https://docs.docker.com/compose/install/)  
3. **Hyperledger Fabric**  
   - Download Hyperledger Fabric binaries:  
     ```bash
     curl -sSL https://bit.ly/2ysbOFE | bash -s
     ```
   - Add binaries to PATH:
     ```bash
     export PATH=$PATH:$(pwd)/bin
     ```
4. **Python 3** (with libraries: `pandas`, `matplotlib`, `numpy`)  
   ```bash
   pip3 install pandas matplotlib numpy
   ```

---

### **Project Setup**
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/tcc-optimization.git
   cd tcc-optimization
   ```
2. Start Hyperledger Fabric Test Network:
   ```bash
   cd fabric-samples/test-network
   ./network.sh up createChannel -ca
   ```

3. Copy benchmark scripts into the working directory:
   ```bash
   cp ../scripts/* .
   ```

---

## **4. Scripts Overview**

### **1. run_benchmark.sh**
- Ensures permissions for all scripts  
- Runs sequential and parallel benchmarks  
- Generates comparative plots  
- Outputs key logs and results  

### **2. create_assets_sequential.sh**
- Runs hashing algorithms sequentially.  
- Logs individual asset hash details, latencies, and resource usage.  
- Generates a summary CSV and log file for analysis.

### **3. create_assets_parallel.sh**
- Runs hashing algorithms in parallel using background processes.  
- Measures total execution time, latency, and resource usage.  
- Outputs per-asset logs and a summary CSV.

### **4. plot_results.py**
- Generates comparative plots for:  
   - Total Execution Time  
   - Throughput  
   - Average Latency  
   - CPU and Memory Usage  
   - Relative Improvement in Throughput and Time  

---

## **5. Running the Benchmark**

1. Ensure the network is up:
   ```bash
   ./network.sh up
   ```
2. Run the benchmark:
   ```bash
   ./run_benchmark.sh
   ```

---

## **6. Generated Plots and Results**
The results generated during the benchmarking process are saved in the `plots/` directory, and I've already organized some of them by the number of assets processed (e.g., `10_assets`, `100_asset`s, `1000_assets`). Each folder contains the plots comparing the performance of hashing algorithms executed sequentially and in parallel.

- **Total Time Comparison** (`total_time_comparison.png`): Compares the total execution time (in milliseconds) for each hashing algorithm between sequential and parallel execution modes.
- **Throughput Comparison** (`throughput_comparison.png`): Displays the number of assets processed per second (throughput) for each algorithm.
- **Avg CPU Usage** (`avg_cpu_%_comparison.png`): Compares the average CPU usage percentage for sequential and parallel modes.
- **Peak CPU Usage** (`peak_cpu_%_comparison.png`): Highlights the peak CPU usage observed for each hashing algorithm. 
- **Avg Latency** (`avg_latency_ms_comparison.png`): Shows the average latency (in milliseconds) for processing each asset. 
- **Relative Improvement in Throughput** (`relative_throughput_improvement.png`): Demonstrates the relative improvement (%) in throughput achieved when switching from sequential to parallel execution.

**Example Output Directory**:
```
root-level/
│
├── logs/
│   ├── master_sequential_metrics.csv
│   ├── master_parallel_metrics.csv
│
├── plots/
│   ├── 10_assets/
│   │   ├── total_time_comparison.png
│   │   ├── throughput_comparison.png
│   │   ├── avg_cpu_%_comparison.png
│   │   ├── peak_cpu_%_comparison.png
│   │   ├── avg_latency_ms_comparison.png
│   │   ├── relative_throughput_improvement.png
│   │   └── relative_total_time_improvement.png
│   │
│   ├── 100_assets/
│   │   ├── total_time_comparison.png
│   │   ├── throughput_comparison.png
│   │   ├── avg_cpu_%_comparison.png
│   │   └── ...
│   │
│   ├── 1000_assets/
│   │   ├── total_time_comparison.png
│   │   ├── throughput_comparison.png
│   │   ├── avg_cpu_%_comparison.png
│   │   └── ...
│
└── bash_scripts/
    ├── create_assets_sequential.sh
    ├── create_assets_parallel.sh
    ├── run_benchmark.sh
    └── plot_results.py
```

---

## **7. Results Analysis**

1. **Performance Improvement**:  
   - Parallel execution significantly reduces the **Total Time** and increases **Throughput**.  

2. **BLAKE3 Performance**:  
   - BLAKE3 consistently outperforms others in both sequential and parallel modes due to its design for parallel processing.  

3. **Resource Utilization**:  
   - CPU usage is higher for parallel processing.  
   - Memory usage remains within acceptable limits.

---

## **8. Future Improvements**
- Integrate post-quantum signature schemes (e.g., SPHINCS+, CRYSTALS-DILITHIUM).  
- Optimize multithreading using libraries like OpenMP or GNU Parallel.  
- Simulate realistic blockchain workloads using larger datasets.  
- Implement hybrid cryptography in a real Hyperledger Fabric network.  

---

## **Conclusion**  
This project demonstrates how parallel hashing improves blockchain transaction efficiency. The benchmarks provide significant conclusions into algorithm performance, resource usage, and optimization opportunities.

---