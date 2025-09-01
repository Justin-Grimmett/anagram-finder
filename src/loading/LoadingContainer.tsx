// Note currently this is the only version
// But potentially in the future could make this dynamic, to allow for different colours from the requirements of the specific web page

import React from 'react';
import Loading from './Loading';

interface LoadingContainerProps {
	isLoading: boolean;
	loadingLabel: string;
}

const LoadingContainer: React.FC<LoadingContainerProps> = ({ isLoading, loadingLabel }) => (
	<div className="loading-container">
		<Loading
			show={isLoading}											 // Show or hide?
			config={{
				boxBackgroundColour: 	'rgba(48, 48, 48, 0.3)'		// Darker grey with low transparency

				, spinColour : 			'rgba(0,0,0,1)'				// Black, fully opaque
				, circleColour:			'rgba(255,255,255,1)'			// White, fully opaque
				, labelFontColour:	 	'rgba(0,0,0,1)'				// Black, fully opaque
			}}
			label={loadingLabel}										 // The text label
		/>
	</div>
);

export default LoadingContainer;
