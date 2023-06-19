import React, { useState } from 'react';
import './App.css';

function App() {
  const [workout, setWorkout] = useState('');

  const getWorkout = async (level) => {
    try {
      const response = await fetch(`https://j1ao83l0ba.execute-api.us-east-2.amazonaws.com/prod/workout?level=${level}`);
      const data = await response.json();
      setWorkout(data.workout);
    } catch (error) {
      console.error('Error fetching the workout:', error);
    }
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
            <h2>Workout Plan:</h2>
            <p>{workout}</p>
          </div>
        )}
      </header>
    </div>
  );
}

export default App;
