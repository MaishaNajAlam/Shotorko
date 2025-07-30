import React, { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { firestore } from "./firebaseConfig";
import { doc, getDoc, updateDoc } from "firebase/firestore";
import policeLogo from "./bangladesh-police-logo.png";

function AlertDetails() {
  const { alertId } = useParams();
  const [currentAlert, setCurrentAlert] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const fetchAlert = async () => {
      setLoading(true);
      try {
        const docRef = doc(firestore, "alerts", alertId);
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          setCurrentAlert({ id: docSnap.id, ...docSnap.data() });
        } else {
          setError("Alert not found");
        }
      } catch (err) {
        setError("Failed to fetch alert");
        console.error(err);
      }
      setLoading(false);
    };

    fetchAlert();
  }, [alertId]);

  const updateStatus = async (newStatus) => {
    try {
      const alertRef = doc(firestore, "alerts", alertId);
      await updateDoc(alertRef, { status: newStatus });
      setCurrentAlert((prev) => ({ ...prev, status: newStatus }));
      window.alert(`Alert status updated to "${newStatus}"`);
      navigate("/alerts");
    } catch (err) {
      console.error("Error updating status:", err);
      window.alert("Failed to update alert status.");
    }
  };

  if (loading) return <p>Loading alert details...</p>;
  if (error) return <p>{error}</p>;

  return (
    <>
      <header>
        <img src={policeLogo} alt="Bangladesh Police Logo" className="logo" />
        <nav>
          <a href="/dashboard">Dashboard</a>
          <a href="/alerts">Alerts</a>
        </nav>
      </header>

      <div className="container details">
        <h2>Alert Details</h2>
        <p>
          <strong>Location:</strong> {currentAlert.location}
        </p>
        <p>
          <strong>Emergency Type:</strong> {currentAlert.emergencyType}
        </p>
        <p>
          <strong>Status:</strong> {currentAlert.status}
        </p>
        <p>
          <strong>Timestamp:</strong>{" "}
          {currentAlert.timestamp?.toDate
            ? currentAlert.timestamp.toDate().toLocaleString()
            : currentAlert.timestamp}
        </p>
        <p>
          <strong>Triggered By:</strong> {currentAlert.triggeredBy}
        </p>

        {currentAlert.status === "New" && (
          <button onClick={() => updateStatus("Ongoing")}>Receive</button>
        )}
        {currentAlert.status === "Ongoing" && (
          <button onClick={() => updateStatus("Resolved")}>Resolve</button>
        )}
        <button onClick={() => navigate("/alerts")} style={{ marginLeft: 10 }}>
          Back to Alerts
        </button>
      </div>
    </>
  );
}

export default AlertDetails;
