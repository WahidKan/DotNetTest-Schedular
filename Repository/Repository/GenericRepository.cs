using Dapper;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Repository.models;
using Repository.Repository.Interface;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repository.Repository
{
    public class GenericRepository<U>: IGenericRepository<U>
    {
        private Config _settings;


        public GenericRepository(IOptions<Config> settings)
        {
            _settings = settings.Value;
        }
        
        public int InsertUpdate<T>(T obj,string SP)
        {

            var sqlConnectionString = GetConnectionString();

            var parameters = new DynamicParameters();
            using (var connection = new SqlConnection(sqlConnectionString))
            {
                connection.Open();
                foreach (var p in obj.GetType().GetProperties().Where(p => !p.GetGetMethod().GetParameters().Any()))
                {

                    if (p.GetValue(obj, null) != null)
                    {
                        parameters.Add($"@{p.Name}", p.GetValue(obj, null));
                    }

                }

                var affectedRows = connection.Execute(SP, parameters, null,null, commandType:CommandType.StoredProcedure);
                connection.Close();
                return affectedRows;
            }
        }

        public List<U> Get<T>(T obj, string SP)
        {
            var sqlConnectionString = GetConnectionString();


            List<U> response = new List<U>();
            using (var connection = new SqlConnection(sqlConnectionString))
            {
                connection.Open();
                var parameters = new DynamicParameters();

                foreach (var p in obj.GetType().GetProperties().Where(p => !p.GetGetMethod().GetParameters().Any()))
                {
                    var resp = p.GetValue(obj, null);
                    if (p.GetValue(obj, null) != null) {
                        parameters.Add($"@{p.Name}", p.GetValue(obj, null));
                    }
                }

                response = connection.Query<U>(SP, parameters, commandType: CommandType.StoredProcedure).ToList();

                connection.Close();
            }
            return response;

        }

        private string GetConnectionString() {

            var sqlConnectionString = _settings.prod;
            #if DEBUG
            sqlConnectionString = _settings.dev;
            #endif
            return sqlConnectionString;
        }
    }
}
