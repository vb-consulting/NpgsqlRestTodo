export const baseUrl = "http://127.0.0.1:5000";
export const parseQuery = (query: Record<any, any>) => "?" + Object.keys(query)
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
