import React, { useEffect, useState } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";

import { auth } from "./firebaseConfig";
import { onAuthStateChanged, signOut } from "firebase/auth";
import "./App.css";
import Login from "./Login";
import Dashboard from "./Dashboard";
import Alerts from "./Alerts";
import AlertDetails from "./AlertDetails";
import Header from "./Header"; // optional

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      setUser(currentUser);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  const handleLogout = () => {
    signOut(auth);
    setUser(null);
  };

  if (loading) return <div className="loading-screen">Loading...</div>;

  return (
    <Router>
      {user && <Header onLogout={handleLogout} />}
      <Routes>
        <Route
          path="/login"
          element={!user ? <Login onLogin={setUser} /> : <Navigate to="/dashboard" replace />}
        />
        <Route
          path="/dashboard"
          element={user ? <Dashboard user={user} /> : <Navigate to="/login" replace />}
        />
        <Route
          path="/alerts"
          element={user ? <Alerts /> : <Navigate to="/login" replace />}
        />
        <Route
          path="/alerts/:alertId"
          element={user ? <AlertDetails /> : <Navigate to="/login" replace />}
        />
        <Route path="*" element={<Navigate to={user ? "/dashboard" : "/login"} replace />} />
      </Routes>
    </Router>
  );
}

export default App;


