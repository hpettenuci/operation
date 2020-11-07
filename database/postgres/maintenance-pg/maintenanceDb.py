import multiprocessing as mp
import sys, datetime, time, logging
import psycopg2
from configparser import ConfigParser

def getConfig(filename='./maintenanceDb.ini', section='postgresql'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    config = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            config[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return config

def connectDb():
    # Get connection parameters
    connectionParams= getConfig(section="postgresql")
    conn = psycopg2.connect(**connectionParams)

    return conn

def getFileTableList(filePath):
    try:
        FILE = open(filePath,'r')
        fileContent = [row for row in FILE.readlines()]
        FILE.close()
        return fileContent
    except FileNotFoundError:
        message = "Error to open file - " + filePath
        logging.info(message)
        sys.exit(message)

def getVacuumTables(dbConn):
    QUERY_EXECUTE_VACUUM =  " SELECT concat(schemaname, '.', relname) " + \
                            " FROM pg_stat_user_tables " + \
                            " WHERE n_live_tup > 100000 " + \
                            " OR n_live_tup < n_dead_tup " + \
                            " OR (n_dead_tup > 0 " + \
                            " AND (n_dead_tup * 100::decimal / n_live_tup) > 1 )" + \
                            " ORDER BY n_dead_tup desc "

    QUERY_EXECUTE_VACUUM =  " SELECT concat(schemaname, '.', relname) " + \
                            " FROM pg_stat_user_tables " + \
                            " ORDER BY n_dead_tup desc "

    queryCursor = dbConn.cursor()
    queryCursor.execute(QUERY_EXECUTE_VACUUM)
    returnData = queryCursor.fetchall()
    queryCursor.close()

    return returnData

def getReindexTables(dbConn):
    QUERY_EXECUTE_REINDEX=  "SELECT  concat(table_schema, '.', table_name) " + \
                            "FROM    information_schema.tables " + \
                            "WHERE   table_type = 'BASE TABLE' " + \
                            "AND     table_schema NOT IN ('pg_catalog', 'information_schema') " + \
                            "ORDER   BY 1 "

    queryCursor = dbConn.cursor()
    queryCursor.execute(QUERY_EXECUTE_REINDEX)
    returnData = queryCursor.fetchall()
    queryCursor.close()

    return returnData

def getAllTables(dbConn):
    QUERY_EXECUTE_ALL = "SELECT  concat(table_schema,'.',table_name) " + \
                        "FROM    information_schema.tables tables " + \
                        "WHERE   table_type = 'BASE TABLE' " + \
                        "AND     table_schema NOT IN ('pg_catalog', 'information_schema') " + \
                        "ORDER   BY 1 "

    queryCursor = dbConn.cursor()
    queryCursor.execute(QUERY_EXECUTE_ALL)
    returnData = queryCursor.fetchall()
    queryCursor.close()

    return returnData

def getReindexIndex(dbConn):
    QUERY_EXECUTE_INDEX =   "SELECT indexname " + \
                            "FROM   pg_indexes  " + \
                            "WHERE  schemaname = 'public' " + \
                            "ORDER BY tablename, indexname "


    queryCursor = dbConn.cursor()
    queryCursor.execute(QUERY_EXECUTE_INDEX)
    returnData = queryCursor.fetchall()
    queryCursor.close()

    return returnData

def executeVacuum(dbTable):
    logging.info("Starting Vacuum on table " + dbTable)

    dbConnQuery = connectDb()
    dbConnQuery.set_session(autocommit=True)
    QUERY_VACUUM = "VACUUM FULL " + dbTable

    queryCursor = dbConnQuery.cursor()
    queryCursor.execute(QUERY_VACUUM)

    logging.info("Vacuum finished on table " + dbTable)

    queryCursor.close()
    dbConnQuery.close()

def executeReindexByTable(dbTable):
    logging.info("Starting Reindex on table " + dbTable)

    dbConnQuery = connectDb()
    dbConnQuery.set_session(autocommit=True)
    QUERY_REINDEX = "REINDEX TABLE " + dbTable

    queryCursor = dbConnQuery.cursor()
    queryCursor.execute(QUERY_REINDEX)

    logging.info("Reindex finished on table " + dbTable)

    queryCursor.close()
    dbConnQuery.close()

def executeReindexByIndex(dbTable):
    logging.info("Starting Reindex on index " + dbTable)

    dbConnQuery = connectDb()
    dbConnQuery.set_session(autocommit=True)
    QUERY_REINDEX = "REINDEX INDEX \"" + dbTable + "\""

    queryCursor = dbConnQuery.cursor()
    queryCursor.execute(QUERY_REINDEX)

    logging.info("Reindex finished on index " + dbTable)

    queryCursor.close()
    dbConnQuery.close()

def execuleAllMaintenance(dbTable):
    logging.info("Starting maintenance on table " + dbTable)

    dbConnQuery = connectDb()
    dbConnQuery.set_session(autocommit=True)
    QUERY_REINDEX = "REINDEX TABLE " + dbTable
    QUERY_VACUUM  = "VACUUM FULL " + dbTable

    queryCursor = dbConnQuery.cursor()
    queryCursor.execute(QUERY_VACUUM)
    queryCursor.execute(QUERY_REINDEX)

    logging.info("Maintenance finished on table " + dbTable)

    queryCursor.close()
    dbConnQuery.close()

if __name__ == '__main__':
    OPERATIONS = [
        "VACUUM",
        "REINDEX",
        "FILE-VACUUM",
        "FILE-REINDEX",
        "ALL",
        "FILE-ALL",
        "REINDEX-IX",
        "FILE-REINDEX-IX"
    ]

    scriptParams = getConfig(section="general")

    LOG_PATH = scriptParams['log_path']
    MAX_THREADS = int(scriptParams['max_threads'])
    WAIT_TIME = int(scriptParams['wait_time'])

    LOG_FILE = LOG_PATH + "/maintenance-db-" + str(datetime.date.today()) + ".log"
    file = open(LOG_FILE, 'a+')
    file.close()
    logging.basicConfig(format='%(asctime)s - %(process)d - %(levelname)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S', filename=LOG_FILE,level=logging.INFO)

    if (len(sys.argv) >= 2):
        scheduleExec = (str(sys.argv[1])).upper()
        if (scheduleExec in OPERATIONS):
            logging.info("Starting " + scheduleExec + " routine...")
        else:
            message = "Invalid operation! Please choose between: VACUUM, REINDEX, FILE-VACUUM, FILE-REINDEX, ALL, FILE-ALL, REINDEX-IX or FILE-REINDEX-IX"
            logging.error(message)
            sys.exit(message)
    else:
        message = "Invalid parameter! Please choose between VACUUM, REINDEX, FILE-VACUUM, FILE-REINDEX, ALL, FILE-ALL, REINDEX-IX or FILE-REINDEX-IX"
        logging.error(message)
        sys.exit(message)

    dbConn = connectDb()
    if scheduleExec == "VACUUM":
        tableList = getReindexTables(dbConn)
    elif scheduleExec == "REINDEX":
        tableList = getVacuumTables(dbConn)
    elif scheduleExec == "REINDEX-IX":
        tableList = getReindexIndex(dbConn)
    elif scheduleExec == "FILE-VACUUM" or scheduleExec == "FILE-REINDEX" or scheduleExec == "FILE-ALL" or scheduleExec == "FILE-REINDEX-IX":
        try:
            FILE_PATH = str(sys.argv[2])
        except IndexError:
            FILE_PATH = scriptParams['file_path']
        finally:        
            tableList = getFileTableList(FILE_PATH)
    elif scheduleExec == 'ALL':
        tableList = getAllTables(dbConn)
    dbConn.close()

    while len(tableList) > 0:
        activeThreads = len(mp.active_children())

        if activeThreads < MAX_THREADS:
            logging.info("Pending items: " + str(len(tableList)) + " Active Threads: " + str(activeThreads))

            if scheduleExec == "VACUUM":
                mp.Process(target=executeVacuum, args=(tableList.pop(0)[0],)).start()
            elif scheduleExec == "REINDEX":
                mp.Process(target=executeReindexByTable, args=(tableList.pop(0)[0],)).start()
            elif scheduleExec == "FILE-VACUUM":
                mp.Process(target=executeVacuum, args=((tableList.pop(0)).rstrip("\n"),)).start()
            elif scheduleExec == "FILE-REINDEX":
                mp.Process(target=executeReindexByTable, args=((tableList.pop(0)).rstrip("\n"),)).start()
            elif scheduleExec == "REINDEX-IX":
                mp.Process(target=executeReindexByIndex, args=(tableList.pop(0)[0],)).start()
            elif scheduleExec == "FILE-REINDEX-IX":
                mp.Process(target=executeReindexByIndex, args=((tableList.pop(0)).rstrip("\n"),)).start()
            elif scheduleExec == "ALL":
                mp.Process(target=execuleAllMaintenance, args=(tableList.pop(0)[0],)).start()
            elif scheduleExec == "FILE-ALL":
                mp.Process(target=execuleAllMaintenance, args=((tableList.pop(0)).rstrip("\n"),)).start()
        else:
            logging.info("Pending items: " + str(len(tableList)) + " Waiting free threads")
            time.sleep(WAIT_TIME)

    while len(mp.active_children()) > 0:
        logging.info("Pending items: " + str(len(tableList)) + " Active Threads: " + str(len(mp.active_children())))
        time.sleep(WAIT_TIME)

    logging.info(scheduleExec + " routine finished...")