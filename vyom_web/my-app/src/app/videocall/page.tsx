"use client";

import React from "react";

const VideoCallPage = () => {
  return (
    <div className="h-screen w-full">
      <iframe
        title="100ms-app"
        allow="camera *; microphone *; display-capture *"
        src="https://simran-videoconf-1239.app.100ms.live/meeting/jte-lwyv-lgi"
        className="w-full h-full border-0"
      ></iframe>
    </div>
  );
};

export default VideoCallPage;
