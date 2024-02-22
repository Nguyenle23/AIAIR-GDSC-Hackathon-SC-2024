import React, { useState } from "react";
import Chart from "./components/charts/Chart";
import Navbar from "./components/navbar/Navbar";
import Map from "./components/map/Map";
import HeaderHCM from "./components/header/HeaderHCM";
import HeaderTD from "./components/header/HeaderTD";
import "./App.css";
import Footer from "./components/footer/footer";
// import { ModelResultProvider } from "./contexts/ModelResultContext";

function App() {
  const [activeHeader, setActiveHeader] = useState("HCM");

  const handleNext = () => {
    setActiveHeader(activeHeader === "HCM" ? "TD" : "HCM");
  };

  const handlePrevious = () => {
    setActiveHeader(activeHeader === "HCM" ? "TD" : "HCM");
  };

  return (
    <>
        <Navbar />
        <div className="container-map">
          <Map />
        </div>
        {activeHeader === "HCM" ? <HeaderHCM /> : <HeaderTD />}
        <div className="slider-controls">
          <button onClick={handlePrevious}>Previous</button>
          <button onClick={handleNext}>Next</button>
        </div>
        <div className="container-chart">
          <Chart />
        </div>
        <Footer />
    </>
  );
}

export default App;
