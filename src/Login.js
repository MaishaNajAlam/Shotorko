import React, { useState } from "react";
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "./firebaseConfig";
import policeLogo from "./bangladesh-police-logo.png"; // Logo in src/

function Login({ onLogin }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const res = await signInWithEmailAndPassword(auth, email, password);
      onLogin(res.user);
      setError("");
    } catch (err) {
      setError("Invalid email or password.");
    }
  };

  return (
    <div className="container login-container">
      <img
        src={policeLogo}
        alt="Bangladesh Police Logo"
        className="police-logo"
      />
      <h2>Police Login</h2>
      <form onSubmit={handleLogin} className="login-form" noValidate>
        <label htmlFor="email">Police Email</label>
        <input
          id="email"
          type="email"
          placeholder="Enter your police email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          autoComplete="username"
        />

        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          placeholder="Enter your password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          autoComplete="current-password"
        />

        <button type="submit">Login</button>
        {error && <p className="error-message">{error}</p>}
      </form>
    </div>
  );
}

export default Login;


