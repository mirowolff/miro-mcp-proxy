function copyCommand(event) {
    event.stopPropagation();
    const command = 'curl -fsSL https://mirowolff.github.io/miro-mcp-proxy/install.sh | bash';

    navigator.clipboard.writeText(command).then(() => {
        const btn = event.currentTarget;
        const copyIcon = btn.querySelector('.copy-icon');
        const checkIcon = btn.querySelector('.check-icon');
        const terminalContent = document.querySelector('.terminal-content');

        // Update button
        copyIcon.style.display = 'none';
        checkIcon.style.display = 'block';
        btn.classList.add('copied');

        // Update terminal box
        terminalContent.classList.add('copied');

        // Reset after 2 seconds
        setTimeout(() => {
            copyIcon.style.display = 'block';
            checkIcon.style.display = 'none';
            btn.classList.remove('copied');
            terminalContent.classList.remove('copied');
        }, 2000);
    });
}

function copyCommandFromBox(element) {
    const command = 'curl -fsSL https://mirowolff.github.io/miro-mcp-proxy/install.sh | bash';

    navigator.clipboard.writeText(command).then(() => {
        const btn = document.querySelector('.copy-btn-circle');
        const copyIcon = btn.querySelector('.copy-icon');
        const checkIcon = btn.querySelector('.check-icon');

        // Update button
        copyIcon.style.display = 'none';
        checkIcon.style.display = 'block';
        btn.classList.add('copied');

        // Update terminal box
        element.classList.add('copied');

        // Reset after 2 seconds
        setTimeout(() => {
            copyIcon.style.display = 'block';
            checkIcon.style.display = 'none';
            btn.classList.remove('copied');
            element.classList.remove('copied');
        }, 2000);
    });

    navigator.clipboard.writeText(command).then(() => {
        const btn = document.querySelector('.copy-btn');
        const copyIcon = btn.querySelector('.copy-icon');
        const checkIcon = btn.querySelector('.check-icon');
        const copyText = btn.querySelector('.copy-text');

        // Update button
        copyIcon.style.display = 'none';
        checkIcon.style.display = 'block';
        copyText.textContent = 'Copied!';
        btn.classList.add('copied');

        // Update terminal box
        element.classList.add('copied');

        // Reset after 2 seconds
        setTimeout(() => {
            copyIcon.style.display = 'block';
            checkIcon.style.display = 'none';
            copyText.textContent = 'Copy';
            btn.classList.remove('copied');
            element.classList.remove('copied');
        }, 2000);
    });
}
