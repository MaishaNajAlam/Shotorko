import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { firestore } from "./firebaseConfig";
import { collection, getDocs } from "firebase/firestore";
import policeLogo from "./bangladesh-police-logo.png";

function Alerts() {
  const [alerts, setAlerts] = useState([]);
  const [filters, setFilters] = useState({
    emergencyType: "",
    status: "",
    location: "",
    triggeredBy: "",
  });
  const [loading, setLoading] = useState(false);

  const navigate = useNavigate();

  const fetchAlerts = async () => {
    setLoading(true);
    try {
      const q = collection(firestore, "alerts");
      const snapshot = await getDocs(q);
      let data = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      if (filters.emergencyType)
        data = data.filter((a) =>
          a.emergencyType
            ?.toLowerCase()
            .includes(filters.emergencyType.toLowerCase())
        );
      if (filters.status)
        data = data.filter(
          (a) => a.status?.toLowerCase() === filters.status.toLowerCase()
        );
      if (filters.location)
        data = data.filter((a) =>
          a.location?.toLowerCase().includes(filters.location.toLowerCase())
        );
      if (filters.triggeredBy)
        data = data.filter((a) =>
          a.triggeredBy?.toLowerCase().includes(filters.triggeredBy.toLowerCase())
        );

      data.sort((a, b) => b.timestamp?.seconds - a.timestamp?.seconds);

      setAlerts(data);
    } catch (error) {
      console.error("Error fetching alerts:", error);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchAlerts();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleFilterChange = (e) => {
    setFilters((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  const handleFilterSubmit = (e) => {
    e.preventDefault();
    fetchAlerts();
  };

  return (
    <>
      <header>
        <img src={policeLogo} alt="Bangladesh Police Logo" className="logo" />
        <nav>
          <a href="/dashboard">Dashboard</a>
          <a href="/alerts">Alerts</a>
          {/* Consider Logout button if needed here */}
        </nav>
      </header>
      <div className="container">
        <h2>Emergency Alerts</h2>

        <form onSubmit={handleFilterSubmit} className="filter-form">
          <input
            type="text"
            name="emergencyType"
            placeholder="Filter by Emergency Type"
            value={filters.emergencyType}
            onChange={handleFilterChange}
          />
          <select name="status" value={filters.status} onChange={handleFilterChange}>
            <option value="">All Status</option>
            <option value="New">New</option>
            <option value="Ongoing">Ongoing</option>
            <option value="Resolved">Resolved</option>
          </select>
          <input
            type="text"
            name="location"
            placeholder="Filter by Location"
            value={filters.location}
            onChange={handleFilterChange}
          />
          <input
            type="text"
            name="triggeredBy"
            placeholder="Filter by User ID"
            value={filters.triggeredBy}
            onChange={handleFilterChange}
          />
          <button type="submit">Search</button>
        </form>

        {loading ? (
          <p>Loading alerts...</p>
        ) : alerts.length === 0 ? (
          <p>No alerts found.</p>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Location</th>
                <th>Emergency Type</th>
                <th>Status</th>
                <th>Timestamp</th>
                <th>Triggered By</th>
              </tr>
            </thead>
            <tbody>
              {alerts.map((alert) => (
                <tr
                  key={alert.id}
                  onClick={() => navigate(`/alerts/${alert.id}`)}
                >
                  <td>{alert.location}</td>
                  <td>{alert.emergencyType}</td>
                  <td>{alert.status}</td>
                  <td>
                    {alert.timestamp?.toDate
                      ? alert.timestamp.toDate().toLocaleString()
                      : alert.timestamp}
                  </td>
                  <td>{alert.triggeredBy}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </>
  );
}

export default Alerts;
