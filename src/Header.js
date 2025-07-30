import React from "react";
import { Link } from "react-router-dom";

function Header({ onLogout }) {
  return (
    <header>
      <div className="logo">🚓 Shotorko Police</div>
      <nav>
        <Link to="/dashboard">Dashboard</Link>
        <Link to="/alerts">Alerts</Link>
        <button onClick={onLogout}>Logout</button>
      </nav>
    </header>
  );
}

export default Header;
