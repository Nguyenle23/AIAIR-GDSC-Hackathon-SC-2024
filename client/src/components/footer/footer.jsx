import React from "react";
import { FaFacebook, FaGithub, FaGooglePlay, FaLinkedin } from "react-icons/fa";
import "./footer.css";

const Footer = () => {
  return (
    <div className="footer">
      <p>
        © 2024 AIoT Lab. All rights reserved.{" "}
      </p>
      <ul className="social-icons">
        <li>
          <a
            href="https://github.com/https://github.com/Nguyenle23"
            target="_blank"
            rel="noopener noreferrer"
          >
            <FaGithub />
          </a>
        </li>
        <li>
          <a
            href="https://www.facebook.com/aiotlab.vn"
            target="_blank"
            rel="noopener noreferrer"
          >
            <FaFacebook />
          </a>
        </li>
        <li>
          <a
            href="https://www.linkedin.com/company/aiot-lab-vn/"
            target="_blank"
            rel="noopener noreferrer"
          >
            <FaLinkedin />
          </a>
        </li>
        <li>
          <a
            href="https://play.google.com/store/apps/details?id=com.aiotlabvn.iu_air_quality"
            target="_blank"
            rel="noopener noreferrer"
          >
            <FaGooglePlay />
          </a>
        </li>
      </ul>
    </div>
  );
};

export default Footer;
