import React from "react";
import { Link } from "react-router-dom";
import policeLogo from "./SHOTORKO.png";
import "./App.css";

function Dashboard({ user, onLogout }) {
  return (
    <>
      <header className="dashboard-header">
        <img src={policeLogo} alt="Bangladesh Police Logo" className="logo" />
        <nav className="dashboard-nav">
          <Link to="/alerts">Alerts</Link>
          <button onClick={onLogout}>Logout</button>
        </nav>
      </header>

      <main className="dashboard-main">
        <h1>Welcome to SHOTORKO</h1>
        <p className="subtext">Bangladesh Police Dashboard</p>
        <div className="info-buttons">
          <p> </p>
          <button className="info-btn">📞 Emergency Hotlines</button>
          <button className="info-btn">❓ FAQ</button>
          <button className="info-btn">ℹ️ About Us</button>
        </div>
      </main>
    </>
  );
}

export default Dashboard;

