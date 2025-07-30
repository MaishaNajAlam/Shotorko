import React from "react";
import { Link } from "react-router-dom";
import policeLogo from "./bangladesh-police-logo.png"; // place the logo file in src folder or public folder

function Dashboard({ user, onLogout }) {
  return (
    <>
      <header>
        <img src={policeLogo} alt="Bangladesh Police Logo" className="logo" />
        <nav>
          <Link to="/dashboard">Dashboard</Link>
          <Link to="/alerts">Alerts</Link>
          <button onClick={onLogout}>Logout</button>
        </nav>
      </header>
      <div className="container">
        <h2>Welcome</h2>
        <p>This is the Police Dashboard.</p>
      </div>
    </>
  );
}

export default Dashboard;
