export default () => ({
    timestamp: new Date().toISOString(),
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    screen: {
        width: window.screen.width,
        height: window.screen.height,
        colorDepth: window.screen.colorDepth,
        pixelRatio: window.devicePixelRatio,
        orientation: screen.orientation.type
    },
    browser: {
        userAgent: navigator.userAgent,
        language: navigator.language,
        languages: navigator.languages,
        cookiesEnabled: navigator.cookieEnabled,
        doNotTrack: navigator.doNotTrack,
        onLine: navigator.onLine,
        platform: navigator.platform,
        vendor: navigator.vendor
    },
    memory: {
        deviceMemory: (navigator as any).deviceMemory,
        hardwareConcurrency: navigator.hardwareConcurrency
    },
    window: {
        innerWidth: window.innerWidth,
        innerHeight: window.innerHeight,
        outerWidth: window.outerWidth,
        outerHeight: window.outerHeight
    },
    location: {
        href: window.location.href,
        hostname: window.location.hostname,
        pathname: window.location.pathname,
        protocol: window.location.protocol,
        referrer: document.referrer
    },
    performance: {
        navigation: {
            type: performance.navigation?.type,
            redirectCount: performance.navigation?.redirectCount
        },
        timing: performance.timing ? {
            loadEventEnd: performance.timing.loadEventEnd,
            loadEventStart: performance.timing.loadEventStart,
            domComplete: performance.timing.domComplete,
            domInteractive: performance.timing.domInteractive,
            domContentLoadedEventEnd: performance.timing.domContentLoadedEventEnd
        } : null
    }
});