import React, { useState } from 'react';

const WorkoutDisplay = () => {
    const [workout, setWorkout] = useState(null);

    const fetchWorkout = (level) => {
        fetch(`https://j1ao83l0ba.execute-api.us-east-2.amazonaws.com/prod/workout?level=${level}`)
            .then(response => response.json())
            .then(data => setWorkout(data.workout))
            .catch(error => console.error('Error fetching workout:', error));
    };

    return (
        <div>
            <h2>Workout of the Day</h2>
            <div>
                <button onClick={() => fetchWorkout('beginner')}>Beginner</button>
                <button onClick={() => fetchWorkout('intermediate')}>Intermediate</button>
                <button onClick={() => fetchWorkout('advanced')}>Advanced</button>
            </div>
            <div>
                {workout && (
                    <div>
                        <h3>Today's Workout:</h3>
                        <pre>{workout}</pre>
                    </div>
                )}
            </div>
        </div>
    );
};

export default WorkoutDisplay;
