using Microsoft.Extensions.Options;
using Repository.models;
using Repository.Repository.Interface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repository.Repository
{
    public class FlatScheduleRepository : GenericRepository<ScheduleResponse>, IFlatScheduleRepository
    {
        public FlatScheduleRepository(IOptions<Config> settings) : base(settings)
        {
        }
    }
}
