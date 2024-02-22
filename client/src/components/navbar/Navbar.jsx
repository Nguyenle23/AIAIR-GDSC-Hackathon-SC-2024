import React, { useState, useRef, useEffect } from "react";
import "./Navbar.css";
import AIoTLogo from "../../assets/aiair.png";

const Navbar = () => {
  const items = [
    {
      id: 1,
      name: "Measures",
      modalContent: {
        title: "Measures",
        content: [
          {
            subtitle: "Air Quality Index(AQI) - US EPA Standard",
            url: "https://www.airnow.gov/aqi/aqi-basics/",
            measureRange: [
              {
                range: "0-50",
                colorBG: "#10b981",
                colorText: "#000",
                qualityAssessment: "Good",
                description:
                  "Air quality is considered satisfactory, and air pollution poses little or no risk.",
              },
              {
                range: "51-100",
                colorBG: "#ffde33",
                colorText: "#000",
                qualityAssessment: "Moderate",
                description:
                  "Air quality is acceptable; however, there may be some health concerns for a few sensitive individuals.",
              },
              {
                range: "101-150",
                colorBG: "#ff9933",
                colorText: "#000",
                qualityAssessment: "Unhealthy for Sensitive Groups",
                description:
                  "Members of sensitive groups may experience health effects. The general public is less likely to be affected.",
              },
              {
                range: "151-200",
                colorBG: "#cc0033",
                colorText: "#000",
                qualityAssessment: "Unhealthy",
                description:
                  "Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects.",
              },
              {
                range: "201-300",
                colorBG: "#660099",
                colorText: "#fff",
                qualityAssessment: "Very Unhealthy",
                description:
                  "Health alert: everyone may experience more serious health effects.",
              },
              {
                range: "301-500",
                colorBG: "#7e0023",
                colorText: "#fff",
                qualityAssessment: "Hazardous",
                description:
                  "Health warnings of emergency conditions. The entire population is more likely to be affected.",
              },
            ],
          },
          {
            subtitle: "Temperature - Standards Guidelines",
            url: "https://www.researchgate.net/publication/363472655_MONITORING_SOLUTIONS_FOR_SMART_AGRICULTURE/figures?lo=1",
            measureRange: [
              {
                range: "0 - 15°C",
                colorBG: "#660099",
                colorText: "#000",
                qualityAssessment: "Very cold",
                description:
                  "Typically no effects, possible drowsiness with prolonged exposure.",
              },
              {
                range: "15 - 25°C",
                colorBG: "#3e66de",
                colorText: "#000",
                qualityAssessment: "Cold",
                description:
                  "May cause headaches, dizziness, nausea, and fatigue in healthy individuals after prolonged exposure",
              },
              {
                range: "25 - 35°C",
                colorBG: "#10b981",
                colorText: "#000",
                qualityAssessment: "Normal",
                description:
                  "Can impair coordination and judgment, and cause vomiting and shortness of breath",
              },
              {
                range: "35 - 45°C",
                colorBG: "#ff9933",
                colorText: "#000",
                qualityAssessment: "Warm",
                description:
                  "Can cause loss of consciousness and death within hours.",
              },
              {
                range: "> 45°C",
                colorBG: "#b5260d",
                colorText: "#fff",
                qualityAssessment: "Hot",
                description: "Can cause death within minutes.",
              },
            ],
          },
          {
            subtitle: "Humidity - Standards Guidelines",
            url: "https://www.airthings.com/en/contaminants/what-is-humidity",
            measureRange: [
              {
                range: "< 25%",
                colorBG: "#660099",
                colorText: "#000",
                qualityAssessment: "Very dry",
                description:
                  "Try drying clothes indoors using a drying rack rather than a tumble dryer. Ensure that you have plenty of ventilation when doing so.",
              },
              {
                range: "25 - 30%",
                colorBG: "#3e66de",
                colorText: "#000",
                qualityAssessment: "Dry",
                description:
                  "Fair humidity levels, keep monitoring. If you have a humidifier, you can use it to increase the humidity in your home.",
              },
              {
                range: "30 - 60%",
                colorBG: "#10b981",
                colorText: "#000",
                qualityAssessment: "Normal",
                description:
                  "Can impair coordination and judgment, and cause vomiting and shortness of breath. Maintain your healthy levels.",
              },
              {
                range: "60 - 70%",
                colorBG: "#ff9933",
                colorText: "#000",
                qualityAssessment: "Humid",
                description:
                  "Can cause loss of consciousness and death within hours. Fair humidity levels, keep monitoring",
              },
              {
                range: "> 70%",
                colorBG: "#b5260d",
                colorText: "#fff",
                qualityAssessment: "Very humid",
                description:
                  "Can cause death within minutes. Running a dehumidifier. Open windows for an hour or two on dry days",
              },
            ],
          },
          {
            subtitle: "CO2 Value - Standards Guidelines",
            url: "https://www.fsis.usda.gov/sites/default/files/media_file/2020-08/Carbon-Dioxide.pdf",
            measureRange: [
              {
                range: "0 - 10,000 ppm",
                colorBG: "#10b981",
                colorText: "#000",
                qualityAssessment: "Normal",
                description:
                  "Typically no effects, possible drowsiness with prolonged exposure.",
              },
              {
                range: "10 - 15,000 ppm",
                colorBG: "#ffde33",
                colorText: "#000",
                qualityAssessment: "Moderate",
                description: "Mild respiratory stimulation for some people.",
              },
              {
                range: "15 - 30,000 ppm",
                colorBG: "#ff9933",
                colorText: "#000",
                qualityAssessment: "Unhealthy",
                description:
                  "Moderate respiratory stimulation, increased heart rate and blood pressure, ACGIH TLV-Short Term.",
              },
              {
                range: "30 - 40,000 ppm",
                colorBG: "#cc0033",
                colorText: "#000",
                qualityAssessment: "Dangerous",
                description: "Immediately Dangerous to Life or Health (IDLH).",
              },
              {
                range: "40 - 50,000 ppm",
                colorBG: "#660099",
                colorText: "#fff",
                qualityAssessment: "Very dangerous",
                description:
                  "Strong respiratory stimulation, dizziness, confusion, headache, shortness of breath.",
              },
              {
                range: "50 - 80,000 ppm",
                colorBG: "#7e0023",
                colorText: "#fff",
                qualityAssessment: "Hazardous",
                description:
                  "Dimmed sight, sweating, tremor, unconsciousness, and possible death.",
              },
            ],
          },
          {
            subtitle: "CO Value - Standards Guidelines",
            url: "https://www.fsis.usda.gov/sites/default/files/media_file/2020-08/Carbon-Monoxide.pdf",
            measureRange: [
              {
                range: "0 - 30 ppm",
                colorBG: "#10b981",
                colorText: "#000",
                qualityAssessment: "Normal",
                description:
                  "Typically no effects, possible drowsiness with prolonged exposure.",
              },
              {
                range: "35 - 50 ppm",
                colorBG: "#ffde33",
                colorText: "#000",
                qualityAssessment: "Moderate",
                description:
                  "May cause headaches, dizziness, nausea, and fatigue in healthy individuals after prolonged exposure",
              },
              {
                range: "50 - 100 ppm",
                colorBG: "#ff9933",
                colorText: "#000",
                qualityAssessment: "Unhealthy",
                description:
                  "Can impair coordination and judgment, and cause vomiting and shortness of breath",
              },
              {
                range: "100 - 200 ppm",
                colorBG: "#660099",
                colorText: "#000",
                qualityAssessment: "Dangerous",
                description:
                  "Can cause loss of consciousness and death within hours.",
              },
              {
                range: "> 200 ppm",
                colorBG: "#7e0023",
                colorText: "#fff",
                qualityAssessment: "Hazardous",
                description: "Can cause death within minutes.",
              },
            ],
          },
          {
            subtitle: "UV Index - Standards Guidelines",
            url: "https://enviro.epa.gov/facts/uv/index.html",
            measureRange: [
              {
                range: "0 - 1",
                colorBG: "#10b981",
                colorText: "#000",
                qualityAssessment: "Normal",
                description:
                  "Typically no effects, possible drowsiness with prolonged exposure.",
              },
              {
                range: "1 - 2",
                colorBG: "#ffde33",
                colorText: "#000",
                qualityAssessment: "Moderate",
                description: "Minimal Risk",
              },
              {
                range: "3 - 5",
                colorBG: "#ff9933",
                colorText: "#000",
                qualityAssessment: "Unhealthy",
                description: "Moderate Risk",
              },
              {
                range: "6 - 7",
                colorBG: "#660099",
                colorText: "#000",
                qualityAssessment: "Dangerous",
                description: "High Risk",
              },
              {
                range: "8 - 10",
                colorBG: "#cc0033",
                colorText: "#000",
                qualityAssessment: "Dangerous",
                description: "Very High Risk",
              },
              {
                range: " > 11",
                colorBG: "#7e0023",
                colorText: "#fff",
                qualityAssessment: "Very dangerous",
                description: "Extreme Risk",
              },
            ],
          },
          {
            subtitle: "Particular Matter 2.5 (PM2.5) - Standards Guidelines",
            url: "https://ecmwf-projects.github.io/copernicus-training-cams/proc-aq-index.html",
            measureRange: [
              {
                range: "0 - 10",
                colorBG: "#10b981",
                colorText: "#000",
                qualityAssessment: "Very good",
                description:
                  "Typically no effects, possible drowsiness with prolonged exposure.",
              },
              {
                range: "10 - 20",
                colorBG: "#ffde33",
                colorText: "#000",
                qualityAssessment: "Good",
                description: "Normal",
              },
              {
                range: "20 - 25",
                colorBG: "#ff9933",
                colorText: "#000",
                qualityAssessment: "Medium",
                description: "Moderate Risk",
              },
              {
                range: "25 - 50",
                colorBG: "#660099",
                colorText: "#000",
                qualityAssessment: "Poor",
                description: "High Risk",
              },
              {
                range: "50 - 75",
                colorBG: "#cc0033",
                colorText: "#000",
                qualityAssessment: "Dangerous",
                description: "Very High Risk",
              },
              {
                range: "75 - 800",
                colorBG: "#7e0023",
                colorText: "#fff",
                qualityAssessment: "Extremely dangerous",
                description: "Extreme Risk",
              },
            ],
          },
        ],
      },
    },
    {
      id: 2,
      name: "Publications",
      modalContent: {
        title: "Publications",
        content: [
          {
            conference:
              "Intelligence of Things: Technologies and Applications 2023 (ICIT 2023). Lecture Notes on Data Engineering and Communications Technologies, vol 188. Springer",
            title:
              "Real-Time Air Quality Monitoring System Using Fog Computing Technology",
            authors:
              "Le, T.D., Le, N.B.N., Truong, N.M.Q., Nguyen, H.P.T., Huynh, KT",
            link: "https://doi.org/10.1007/978-3-031-46749-3_15",
          },
          {
            conference:
              "The 16th National Conference on Basic Research and Application of Information Technology (FAIR 2023). Accepted (September 2023)",
            title:
              "An AIoT System for Real-Time Air Quality Monitoring and Forecasting",
            authors:
              "Binh Nguyen Le Nguyen, Nam Anh Dang Nguyen, Duc Dang Khoi Nguyen, Le Duy Tan",
            link: "https://drive.google.com/file/d/1hq2E2Cl8nB3ATfGPzpBq0Ep1bHHkBP6p/view?usp=sharing",
          },
        ],
      },
    },
    {
      id: 3,
      name: "FAQs",
      modalContent: {
        title: "FAQs",
        content: [
          {
            question: "What is the AIAir Quality System?",
            answer:
              "The AIAir Quality System is a system that allows you to monitor the air quality in your home or office. It also allows you to monitor in real-time and forcaste the air quality through web and mobile applications.",
          },
          {
            question: "How does the AIAir Quality System work?",
            answer:
              "The AIAir Quality System works by using a hardware device with multiple environmental sensors to measure each toxic components include temperature, humidity, co2 value, co value, pm2.5 and uv index. It then sends the data to the AIAir Quality System server, which then sends the data to both web and mobile AIAir Quality System application. The AIAir Quality System app then displays the data in a graph and map.",
          },
          {
            question:
              "What are the benefits of using the AIAir Quality System?",
            answer:
              "The AIAir Quality System allows you to monitor the air quality in real-time. It also allows you to forecast the air quality by choose the time you want to forecast or the algorithms to forecast.",
          },
          {
            question: "How much does the AIAir Quality System cost?",
            answer:
              "The AIAir Quality System current operates on a free basis.",
          },
          {
            question: "How do I install the AIAir Quality System?",
            answer:
              'The AIAir Quality System is easy to install. All you have to do is searching it on Google Play Store with "AIAir Quality App" and download it.',
          },
          {
            question: "How do I use the AIAir Quality System?",
            answer:
              "The AIAir Quality System is easy to use. All you have to do is accessing the web application via https://www.aiair-aiotlabvn.tech/ and use it. For mobile application, you can download it on Google Play Store via https://play.google.com/store/apps/details?id=com.aiotlabvn.iu_air_quality",
          },
          {
            question: "How do I contact customer support?",
            answer:
              "You can contact customer support by emailing us at AIoTLabVN on facebook, linkedin and our websize: https://aiotlab.vn/",
          },
        ],
      },
    },
    {
      id: 4,
      name: "About",
      modalContent: {
        title: "About",
        content: [
          {
            reason:
              "AIAir is an air quality monitoring system that uses AIoT technology to monitor the air quality in your home or office.",
            developers:
              "AIAir is developed by AIoTLabVN, a student from the International University, Vietnam National University Ho Chi Minh City.",
            majors:
              "AIAir is bachelor's thesis of student: Le Nguyen Binh Nguyen with supervisor Dr. Le Duy Tan.",
            contact:
              "If you have any questions, please contact us at AIoTLabVN",
            logoAIAir:
              "https://res.cloudinary.com/nguyenle23/image/upload/v1703403428/aiair_femkrw.png",
            logoAIoTLabVN:
              "https://res.cloudinary.com/nguyenle23/image/upload/v1703403333/aiot_logo_rmbg_uyord7.png",
            qrCode:
              "https://res.cloudinary.com/nguyenle23/image/upload/v1703403332/qr_rmbg_jw4jix.png",
          },
        ],
      },
    },
  ];

  const [modalContent, setModalContent] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const modalRef = useRef(null);

  const openModal = (content) => {
    setModalContent(content);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setModalContent("");
    setIsModalOpen(false);
  };

  const handleOutsideClick = (e) => {
    if (modalRef.current && !modalRef.current.contains(e.target)) {
      closeModal();
    }
  };

  useEffect(() => {
    document.addEventListener("mousedown", handleOutsideClick);

    return () => {
      document.removeEventListener("mousedown", handleOutsideClick);
    };
  }, []);

  return (
    <div className="navbar">
      <div className="navbar__container">
        <div className="navbar__left">
          <img src={AIoTLogo} alt="logo_aiot_lab_vn" className="navbar__logo" />
          <span>AIAir Quality System</span>
        </div>
        <div className="navbar__right">
          <ul className="navbar__items">
            {items.map((item) => (
              <li
                key={item.id}
                className="navbar__item activate"
                onClick={() => openModal(item.modalContent)}
              >
                {item.name}
              </li>
            ))}
          </ul>
        </div>
      </div>
      {isModalOpen && (
        <div className="modal-overlay">
          <div ref={modalRef} className="modal">
            <div className="modal-header">
              <h2 className="modal-title">{modalContent.title}</h2>
              <button className="close-button" onClick={closeModal}>
                X
              </button>
            </div>
            <div className="modal-content">
              {modalContent.title === "Measures" && (
                <>
                  {modalContent.content.map((item, index) => (
                    <div key={index} className="modal-content-item">
                      <div className="modal-content-item__subtitle">
                        <span>
                          {index}. {item.subtitle}{" "}
                        </span>
                        | {""}
                        <a
                          href={item.url}
                          target="_blank"
                          rel="noreferrer"
                          className="modal-content-item__link"
                        >
                          Reference
                        </a>
                      </div>
                      <br />
                      <table className="modal-content-table">
                        <thead>
                          <tr>
                            <th>Range</th>
                            <th>Quality Assessment</th>
                            <th>Description</th>
                          </tr>
                        </thead>
                        <tbody>
                          {item.measureRange.map((item, index) => (
                            <tr
                              key={index}
                              className="modal-content-item-table"
                            >
                              <td
                                style={{
                                  backgroundColor: item.colorBG,
                                  color: item.colorText,
                                }}
                                className="modal-range"
                              >
                                {item.range}
                              </td>
                              <td
                                style={{
                                  backgroundColor: item.colorBG,
                                  color: item.colorText,
                                }}
                              >
                                {item.qualityAssessment}
                              </td>
                              <td
                                style={{
                                  backgroundColor: item.colorBG,
                                  color: item.colorText,
                                }}
                              >
                                {item.description}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                      <br />
                    </div>
                  ))}
                </>
              )}
              {modalContent.title === "Publications" &&
                modalContent.content.map((item, index) => (
                  <div key={index} className="modal-content-item">
                    <div className="modal-content-item__conference">
                      [{index}]. <span>Conference Name: {item.conference}</span>
                    </div>
                    <div className="modal-content-item__title">
                      <span>Paper name: {item.title}</span>
                    </div>
                    <div className="modal-content-item__authors">
                      <span>Authors: {item.authors}</span>
                    </div>
                    <div className="modal-content-item__link">
                      {item.link == "" ? (
                        <span>Link paper: Update soon</span>
                      ) : (
                        <>
                          Link paper: {""}
                          <a href={item.link} target="_blank" rel="noreferrer">
                            {item.link}
                          </a>
                        </>
                      )}
                    </div>
                    <br />
                  </div>
                ))}
              {modalContent.title === "FAQs" &&
                modalContent.content.map((item, index) => (
                  <div key={index} className="modal-content-item">
                    <div className="modal-content-item__question">
                      <span>
                        {index}. {item.question}
                      </span>
                    </div>
                    <div className="modal-answer">
                      <span>{item.answer}</span>
                    </div>
                    <br />
                  </div>
                ))}
              {modalContent.title === "About" &&
                modalContent.content.map((item, index) => (
                  <div key={index} className="modal-content-item">
                    <div className="modal-answer">
                      <span>1. {item.reason}</span>
                    </div>
                    <div className="modal-answer">
                      <span>2. {item.developers}</span>
                    </div>
                    <div className="modal-answer">
                      <span>3. {item.majors}</span>
                    </div>
                    <div className="modal-answer">
                      <span>4. {item.contact}</span>
                    </div>
                    <br />
                    <div className="modal-content-item__logo">
                      <img src={item.qrCode} alt="qr_code" />
                      <img src={item.logoAIAir} alt="logo_aiair" />
                      <img
                        style={{
                          height: "100px",
                          width: "90px",
                          objectFit: "cover",
                        }}
                        src={item.logoAIoTLabVN}
                        alt="logo_aiot_lab_vn"
                      />
                    </div>
                    <br />
                  </div>
                ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Navbar;
