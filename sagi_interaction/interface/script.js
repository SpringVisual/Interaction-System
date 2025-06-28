const wrapper = document.querySelector('.interaction-wrapper');
const progressCircle = document.querySelector('.progress-ring-circle');
const labelText = document.getElementById('label-text');
const labelIcon = document.getElementById('label-icon');

const radius = progressCircle.r.baseVal.value;
const circumference = radius * 2 * Math.PI;
progressCircle.style.strokeDasharray = `${circumference} ${circumference}`;
progressCircle.style.strokeDashoffset = circumference;
let progressTimer = null;
window.addEventListener('message', function(event) {
    const data = event.data;
    switch (data.action) {
        case 'show':
            labelText.textContent = data.text;
            labelIcon.className = data.icon || 'fa-solid fa-hand-pointer';
            wrapper.style.display = 'flex';
            setProgress(0);
            break;
        case 'hide':
            wrapper.style.display = 'none';
            if (progressTimer) {
                clearInterval(progressTimer);
                progressTimer = null;
            }
            break;

        case 'startProgress':
            startProgress(data.duration);
            break;
        case 'cancelProgress':
            if (progressTimer) {
                clearInterval(progressTimer);
                progressTimer = null;
            }
            setProgress(0);
            break;
            
        default:
            break;
    }
});

function setProgress(percent) {
    const offset = circumference - (percent / 100) * circumference;
    progressCircle.style.strokeDashoffset = offset;
}

function startProgress(duration) {
    if (progressTimer) {
        clearInterval(progressTimer);
    }
    let startTime = Date.now();
    progressTimer = setInterval(() => {
        let now = Date.now();
        if (now >= startTime + duration) {
            clearInterval(progressTimer);
            progressTimer = null;
            setProgress(100);
            const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'sagi_interaction';
            fetch(`https://${resourceName}/interactionSuccess`, { 
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({})
            }).catch(err => console.error("Could not fetch:", err));
            wrapper.style.display = 'none';
        } else {
            let percent = ((now - startTime) / duration) * 100;
            setProgress(percent);
        }
    }, 10);
}