/**
 * Mark segment in a string with tags
 *
 * @param source string to mark a segment in
 * @param search a segment to mark
 * @param open opening tag
 * @param open closing tag
 */
export default function mark(
    source: string,
    search: string,
    open = "<span class='mark'>",
    close = "</span>"
) {
    if (!source) {
        return source;
    }
    if (!search) {
        return source;
    }
    const index = source.toLowerCase().indexOf(search.toLowerCase());
    if (index !== -1) {
        const segment = source.substring(index, index + search.length);
        return `${source.substring(0, index)}${open}${segment}${close}${source.substring(
            index + search.length,
            source.length
        )}`;
    }
    return source;
}
