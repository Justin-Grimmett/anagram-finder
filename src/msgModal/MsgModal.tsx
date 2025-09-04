import React, { FC } from 'react';
import parse from 'html-react-parser';		// Allows HTML tags to be used within React strings

interface MsgModalProps {
	isOpen: boolean;			// show or hide?
	onClose: () => void;
	title: string;				// the text title at the top
	body: string;				// the main body contents text
	btnLabel:string 			// the text label of the button at the bottom - eg Close
}

const modalStyles: React.CSSProperties = {
	position: 'fixed',
	top: '50%',
	left: '50%',
	width: '90vw',
	maxWidth: '400px',
	height: 'auto',
	minHeight: '200px',			// Minimum height desired
	maxHeight: '80vh',			// Maximum height (majority of mobile viewport)
	background: 'rgba(241,241,241,1)',	// Slightly off-white
	boxShadow: '0 2px 8px 10px rgba(0,0,0,0.26)',		// [offset-x] [offset-y] [blur-radius] [spread-radius] [color] [inset];
	borderRadius: '50px',		// rounded corners
	transform: 'translate(-50%, -50%)',
	zIndex: 1000,
	display: 'flex',
	flexDirection: 'column',
	padding: '16px',
};

// This is the disabled main screen behind the modal
const backdropStyles: React.CSSProperties = {
	position: 'fixed',
	top: 0,
	left: 0,
	height: '100vh',
	width: '100vw',
	background: 'rgba(0,0,0,0.2)',
	zIndex: 999,
};

const bodyStyles: React.CSSProperties = {
	flex: '1 1 auto',
	overflowY: 'auto',
	margin: '16px 0',
	};

const MsgModal: FC<MsgModalProps> = ({
	isOpen,
	onClose,
	title,
	body,
	btnLabel
}) => {
	if (!isOpen) return null;
	return (
		<>
		<div style={backdropStyles}></div>
		<div style={modalStyles} role="dialog" aria-modal="true">
			<h2>{title}</h2>
			<div style={bodyStyles}>{parse(body)}</div>
			<button
				style={{
					marginTop: 'auto',
					alignSelf: 'center',
					padding: '10px 24px',
					fontSize: '18px'
				}}
				onClick={onClose}
			>
				{btnLabel}
			</button>
		</div>
		</>
	);
};

export default MsgModal;
