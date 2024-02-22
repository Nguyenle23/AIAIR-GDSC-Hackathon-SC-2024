import React, { createContext, useState } from 'react';

export const ModelResultContext = createContext();

export const ModelResultProvider = ({ children }) => {
  const [selectedModelResult, setSelectedModelResult] = useState(null);

  return (
    <ModelResultContext.Provider value={{ selectedModelResult, setSelectedModelResult }}>
      {children}
    </ModelResultContext.Provider>
  );
};
