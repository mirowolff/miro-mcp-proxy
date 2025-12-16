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
}

function copyCommandNav(event) {
    event.stopPropagation();
    const command = 'curl -fsSL https://mirowolff.github.io/miro-mcp-proxy/install.sh | bash';

    navigator.clipboard.writeText(command).then(() => {
        const navBtn = event.currentTarget;
        const navCopyIcon = navBtn.querySelector('.copy-icon-nav');
        const navCheckIcon = navBtn.querySelector('.check-icon-nav');

        const terminalContent = document.querySelector('.terminal-content');
        const circleBtn = document.querySelector('.copy-btn-circle');

        // Update nav button
        if (navCopyIcon && navCheckIcon) {
            navCopyIcon.style.display = 'none';
            navCheckIcon.style.display = 'block';
            navBtn.classList.add('copied');
        }

        // Update circle button
        if (circleBtn) {
            const circleCopyIcon = circleBtn.querySelector('.copy-icon');
            const circleCheckIcon = circleBtn.querySelector('.check-icon');
            if (circleCopyIcon && circleCheckIcon) {
                circleCopyIcon.style.display = 'none';
                circleCheckIcon.style.display = 'block';
                circleBtn.classList.add('copied');
            }
        }

        // Update terminal box
        if (terminalContent) {
            terminalContent.classList.add('copied');
        }

        // Reset after 2 seconds
        setTimeout(() => {
            if (navCopyIcon && navCheckIcon) {
                navCopyIcon.style.display = 'block';
                navCheckIcon.style.display = 'none';
                navBtn.classList.remove('copied');
            }

            if (circleBtn) {
                const circleCopyIcon = circleBtn.querySelector('.copy-icon');
                const circleCheckIcon = circleBtn.querySelector('.check-icon');
                if (circleCopyIcon && circleCheckIcon) {
                    circleCopyIcon.style.display = 'block';
                    circleCheckIcon.style.display = 'none';
                    circleBtn.classList.remove('copied');
                }
            }

            if (terminalContent) {
                terminalContent.classList.remove('copied');
            }
        }, 2000);
    });
}
