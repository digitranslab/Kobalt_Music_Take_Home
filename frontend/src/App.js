import React, { useState } from 'react';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = (e) => {
    e.preventDefault();
    if (username === 'username' && password === 'password') {
      setIsAuthenticated(true);
    } else {
      alert('Invalid credentials');
    }
  };

  // Mock data for EMR clusters
  const [clusters, setClusters] = useState([
    { id: '1', name: 'temp-ad-hoc-cluster-1', runningHours: 6 },
    { id: '2', name: 'temp-ad-hoc-cluster-2', runningHours: 3 },
    { id: '3', name: 'temp-ad-hoc-cluster-3', runningHours: 8 },
  ]);

  const terminateCluster = (clusterId) => {
    // Remove the terminated cluster from the list
    setClusters(clusters.filter(cluster => cluster.id !== clusterId));
  };

  return (
    <div className="App">
      {!isAuthenticated ? (
        <div className="hero">
          <h1>Welcome to EMR Monitoring Dashboard</h1>
          <form onSubmit={handleLogin}>
            <input
              type="text"
              placeholder="Username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <button type="submit">Login</button>
          </form>
        </div>
      ) : (
        <div>
          <h1>EMR Cluster Monitoring Dashboard</h1>
          <ul>
            {clusters.map(cluster => (
              <li key={cluster.id}>
                {cluster.name} - Running for {cluster.runningHours} hours
                {cluster.runningHours > 5 && (
                  <button onClick={() => terminateCluster(cluster.id)}>Terminate</button>
                )}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

export default App; 