export const baseUrl = document.location.origin;
export const parseQuery = (query: Record<any, any>) => "?" + Object.keys(query ? query : {})
    .map(key => {{
        const value = query[key] != null ? query[key] : "";
        if (Array.isArray(value)) {{
            return value.map(s => {
                if (!s) return key + "=";
                return key + "=" + encodeURIComponent(s);
            }).join("&");
        }}
        return key + "=" + encodeURIComponent(value);
    }})
    .join("&");
