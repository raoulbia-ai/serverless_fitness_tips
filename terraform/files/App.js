import React, { useState } from 'react';
import './App.css';

function App() {
  const [workout, setWorkout] = useState('');
  const [selectedLevel, setSelectedLevel] = useState('');
  const [workoutDate, setWorkoutDate] = useState('');

  const getWorkout = async (level) => {
    try {
      const response = await fetch(`https://<API_INVOKE_URL>/workout?level=${level}`);
      const data = await response.json();
      setWorkout(data.workout);
      setSelectedLevel(level.charAt(0).toUpperCase() + level.slice(1)); // Capitalize the first letter
      setWorkoutDate(new Date().toLocaleDateString()); // Set today's date
    } catch (error) {
      console.error('Error fetching the workout:', error);
    }
  };

  const formatWorkoutSections = (workoutText) => {
    const sections = workoutText.split('\n\n');
    return sections.map((section, index) => (
      <div key={index}>
        <h3>{section.split('\n')[0]}</h3>
        <p>{section.split('\n').slice(1).join('\n')}</p>
      </div>
    ));
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Fitness Workout Generator</h1>
        <div>
          <button onClick={() => getWorkout('beginner')}>Beginner Workout</button>
          <button onClick={() => getWorkout('intermediate')}>Intermediate Workout</button>
          <button onClick={() => getWorkout('advanced')}>Advanced Workout</button>
        </div>
        {workout && (
          <div>
            <h2>The {selectedLevel} Workout for {workoutDate} is:</h2>
            {formatWorkoutSections(workout)}
          </div>
        )}
      </header>
    </div>
  );
}

export default App;
