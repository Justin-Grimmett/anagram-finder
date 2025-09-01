import React from 'react';
import './Loading.css'

interface LoadingProps {
	// Show or hide?
	show: boolean;  
	// Appearance configuration
	config: { 
		boxBackgroundColour: string,
		spinColour: string,
		circleColour: string,
		labelFontColour: string
	};
	// Text label
	label?: string;
}

const Loading: React.FC<LoadingProps> = ({ show, config, label }) => {
	if (!show) return null;	// Hide
	return (
		<>
		{/* Full screen invisible overlay to block interaction with user controls */}
		<div
			style={{
				position: 'fixed',
				top: 0, left: 0, right: 0, bottom: 0,	// full screen
				backgroundColor: 'rgba(230,230,230,0.5)', // Light grey, half transparent
				zIndex: 999,  // On top of most other controls (aside from the loading block below)
			}}
		/>

		{/* Centered loading block with darker partially opaque background behind the icon and label text */}
		<div
			style={{
				position: 'fixed',
				top: '50%',
				left: '50%',
				transform: 'translate(-50%, -50%)',
				background: config.boxBackgroundColour,  // Background colour of the opaquq block directly behind the loading icon and text
				borderRadius: '14px',	// The rounded corners of the box
				padding: '24px 40px',
				display: 'flex',
				flexDirection: 'column',
				alignItems: 'center',
				zIndex: 1000,   // In front of the transparent background above
				boxShadow: '0 0 15px rgba(0,0,0,0.7)',
				minWidth: '120px'
				// Dyamic CSS
				, '--circle-colour': config.circleColour
				, '--spin-colour': config.spinColour
			} as React.CSSProperties}
		>
		<div className="spinner" />
			{label && label.trim() !== '' && (
				<span style={{ marginTop: '12px', fontSize: '16px', textAlign: 'center', color: config.labelFontColour, fontWeight: 'bold' }}>
					{label}
				</span>
			)}
		</div>
		</>
	);
};

export default Loading;
