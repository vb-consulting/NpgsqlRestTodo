import postgres from 'postgres'
import { warning, error, info, notice } from './log.js';

/**
 * @returns {import('postgres').Sql<{}>}
 */
export default () => {
    return postgres({ 
        onnotice: (e) => {
            if (e.severity === 'NOTICE') {
                notice(e.message, e.where);
            } else if (e.severity === 'WARNING') {
                warning(e.message, e.where);
            } else if (e.severity === 'ERROR') {
                error(e.message, e.where);
            } else {
                info(e.message, e.where);
            }
        }
    });
}
