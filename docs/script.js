const INSTALL_COMMAND = 'curl -fsSL https://mirowolff.github.io/miro-mcp-proxy/install.sh | bash';

// Helper function to toggle icon visibility and state
function toggleCopyState(button, iconClass, checkClass, isCopied) {
    if (!button) return;

    const copyIcon = button.querySelector(iconClass);
    const checkIcon = button.querySelector(checkClass);

    if (copyIcon && checkIcon) {
        copyIcon.style.display = isCopied ? 'none' : 'block';
        checkIcon.style.display = isCopied ? 'block' : 'none';
        button.classList.toggle('copied', isCopied);
    }
}

// Copy command from circular button inside terminal
function copyCommand(event) {
    event.stopPropagation();

    navigator.clipboard.writeText(INSTALL_COMMAND).then(() => {
        const circleBtn = event.currentTarget;
        const terminalContent = document.querySelector('.terminal-content');

        toggleCopyState(circleBtn, '.copy-icon', '.check-icon', true);
        if (terminalContent) terminalContent.classList.add('copied');

        setTimeout(() => {
            toggleCopyState(circleBtn, '.copy-icon', '.check-icon', false);
            if (terminalContent) terminalContent.classList.remove('copied');
        }, 2000);
    });
}

// Copy command from clicking terminal box
function copyCommandFromBox(element) {
    navigator.clipboard.writeText(INSTALL_COMMAND).then(() => {
        const circleBtn = document.querySelector('.copy-btn-circle');

        if (circleBtn) {
            toggleCopyState(circleBtn, '.copy-icon', '.check-icon', true);
        }
        element.classList.add('copied');

        setTimeout(() => {
            if (circleBtn) {
                toggleCopyState(circleBtn, '.copy-icon', '.check-icon', false);
            }
            element.classList.remove('copied');
        }, 2000);
    });
}

// Copy command from navbar button
function copyCommandNav(event) {
    event.stopPropagation();

    navigator.clipboard.writeText(INSTALL_COMMAND).then(() => {
        const navBtn = event.currentTarget;
        const terminalContent = document.querySelector('.terminal-content');
        const circleBtn = document.querySelector('.copy-btn-circle');

        toggleCopyState(navBtn, '.copy-icon-nav', '.check-icon-nav', true);
        if (circleBtn) toggleCopyState(circleBtn, '.copy-icon', '.check-icon', true);
        if (terminalContent) terminalContent.classList.add('copied');

        setTimeout(() => {
            toggleCopyState(navBtn, '.copy-icon-nav', '.check-icon-nav', false);
            if (circleBtn) toggleCopyState(circleBtn, '.copy-icon', '.check-icon', false);
            if (terminalContent) terminalContent.classList.remove('copied');
        }, 2000);
    });
}
